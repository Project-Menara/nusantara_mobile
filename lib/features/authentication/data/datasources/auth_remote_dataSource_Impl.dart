import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(NetworkInfo networkInfo, {required this.client});

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

  @override
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/check-phone');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200) {
        return PhoneCheckResponseModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException(
          json.decode(response.body)['message'] ?? 'Failed to check phone',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
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

      if (response.statusCode != 200) {
        throw ServerException(
          json.decode(response.body)['message'] ?? 'OTP Verification Failed',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/register');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'gender': gender,
        }),
      );

      if (response.statusCode != 201) {
        throw ServerException(
          json.decode(response.body)['message'] ?? 'Registration failed',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
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
      if (response.statusCode != 200) {
        throw ServerException(
          json.decode(response.body)['message'] ?? 'Failed to create PIN',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
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

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        // Ambil objek 'data' dari respons
        final data = jsonResponse['data'];
        // Buat UserModel dari 'user' dan 'token' di dalam 'data'
        return UserModel.fromJson(data['user'], token: data['token']);
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'PIN confirmation failed',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<UserModel> verifyPin({
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

      final jsonResponse = json.decode(response.body);
      print(
        'DEBUG: Respons /login -> $jsonResponse',
      ); // <-- LETAK PRINT DI SINI

      if (response.statusCode == 200) {
        final String token = jsonResponse['data'];
        Map<String, dynamic> decodedPayload = JwtDecoder.decode(token);
        return UserModel.fromJson(decodedPayload, token: token);
      } else if (response.statusCode == 429) {
        final int retrySeconds =
            jsonResponse['error']['retry_after_seconds'] ?? 60;
        throw RateLimitException(jsonResponse['message'], retrySeconds);
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Invalid PIN or phone number',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<void> logout(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/logout');
    try {
      final response = await client.post(uri, headers: _headers(token: token));

      if (response.statusCode != 200) {
        throw ServerException(
          json.decode(response.body)['message'] ?? 'Logout failed',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
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
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['data']; // Mengembalikan String TOKEN
      } else if (response.statusCode == 429) {
        final retrySeconds =
            jsonResponse['error']?['retry_after_seconds'] ?? 60;
        throw RateLimitException(jsonResponse['message'], retrySeconds);
      } else {
        throw AuthException(jsonResponse['message'] ?? 'Login Gagal');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<UserModel> getUserProfile({required String token}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/me');
    try {
      final response = await client.get(uri, headers: _headers(token: token));
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonResponse['data'], token: token);
      } else {
        throw ServerException(
          'Gagal mengambil profil: ${jsonResponse['message']}',
        );
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }
}
