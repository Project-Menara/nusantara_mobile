import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  Map<String, String> _headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    final jsonResponse = json.decode(response.body);
    print(
      "API Response (${response.request?.url}): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else if (response.statusCode == 400) {
      throw ServerException(jsonResponse['message'] ?? 'Bad Request');
    } else if (response.statusCode == 401) {
      // Check if it's token expired
      final message = jsonResponse['message'] ?? 'Unauthorized';
      if (message.toLowerCase().contains('token') &&
          (message.toLowerCase().contains('expired') ||
              message.toLowerCase().contains('invalid') ||
              message.toLowerCase().contains('not found'))) {
        throw AuthException(message, type: AuthErrorType.tokenExpired);
      }
      throw AuthException(message);
    } else if (response.statusCode == 429) {
      final retrySeconds = jsonResponse['error']?['retry_after_seconds'] ?? 60;
      throw RateLimitException(
        jsonResponse['message'] ?? 'Too Many Requests',
        retrySeconds,
      );
    } else {
      // Untuk 500 dan error lainnya
      throw ServerException(jsonResponse['message'] ?? 'Internal Server Error');
    }
  }

  @override
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/check-phone');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber}),
      );
      final jsonResponse = _processResponse(response);
      return PhoneCheckResponseModel.fromJson(jsonResponse['data']);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/code-verify');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'code': code}),
      );
      _processResponse(response);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<RegisterResponseModel> register(RegisterModel register) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/register');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(register.toJson()),
      );
      final jsonResponse = _processResponse(response);
      return RegisterResponseModel.fromJson(jsonResponse['data']);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> createPin({
    required String phoneNumber,
    required String pin,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/new-pin');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );
      _processResponse(response);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<UserModel> confirmPin({
    required String phone,
    required String confirmPin,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/confirm-pin');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phone, 'confirm_pin': confirmPin}),
      );
      final jsonResponse = _processResponse(response);
      final data = jsonResponse['data'];
      return UserModel.fromJson(data['user'], token: data['token']);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  // <<< TAMBAHAN IMPLEMENTASI VALIDASI TOKEN >>>
  @override
  Future<void> validateForgotPinToken(String token) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/validate-forgot-pin?token=$token',
    );
    try {
      final response = await client.get(uri, headers: _headers());
      _processResponse(response);
      final jsonResponse = json.decode(response.body);
      print("API Response validateForgotPinToken: ({$jsonResponse})");
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> setNewPinForgot({
    required String token,
    required String phoneNumber,
    required String pin,
  }) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/new-pin-forgot?token=$token',
    );
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );
      final jsonResponse = json.decode(response.body);
      print("API Response setNewPinForgot :({$jsonResponse})");
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<UserModel> confirmNewPinForgot({
    required String token,
    required String phoneNumber,
    required String confirmPin,
  }) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/confirm-pin-forgot?token=$token',
    );
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'confirm_pin': confirmPin}),
      );

      // PERBAIKAN: Panggil _processResponse dulu
      final jsonResponse = _processResponse(response);

      final data = jsonResponse['data'];
      if (data == null || data['user'] == null || data['token'] == null) {
        throw const ServerException('Format respons tidak valid dari server.');
      }
      return UserModel.fromJson(data['user'], token: data['token']);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<String> loginAndGetToken({
    required String phoneNumber,
    required String pin,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/login');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );
      final jsonResponse = _processResponse(response);
      return jsonResponse['data']; // Mengembalikan String TOKEN
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<UserModel> getUserProfile({required String token}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/me');
    try {
      final response = await client.get(uri, headers: _headers(token: token));
      final jsonResponse = _processResponse(response);
      return UserModel.fromJson(jsonResponse['data'], token: token);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> resendCode(String phoneNumber) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/resend-code-verify');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber}),
      );
      _processResponse(response);
      final jsonResponse = json.decode(response.body);
      print("API Response ({$jsonResponse})");
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<String> forgotPin(String phoneNumber) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/forgot-pin');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber}),
      );
      final jsonResponse = _processResponse(response);
      return jsonResponse['data']['token'];
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> logout(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/logout');
    try {
      final response = await client.post(uri, headers: _headers(token: token));
      _processResponse(response);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }
}
