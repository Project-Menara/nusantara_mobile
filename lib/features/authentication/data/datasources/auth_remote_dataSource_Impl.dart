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

  // DIHAPUS: NetworkInfo tidak digunakan di layer ini
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

  // BARU: Helper method terpusat untuk memproses semua respons HTTP
  dynamic _processResponse(http.Response response) {
    final jsonResponse = json.decode(response.body);
    print("API Response (${response.request?.url}): ${response.statusCode} -> $jsonResponse");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else if (response.statusCode == 400) {
      throw ServerException(jsonResponse['message'] ?? 'Bad Request');
    } else if (response.statusCode == 401) {
      throw AuthException(jsonResponse['message'] ?? 'Unauthorized');
    } else if (response.statusCode == 429) {
      final retrySeconds = jsonResponse['error']?['retry_after_seconds'] ?? 60;
      throw RateLimitException(jsonResponse['message'] ?? 'Too Many Requests', retrySeconds);
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
      // REFACTOR: Panggil helper method
      final jsonResponse = _processResponse(response);
      return PhoneCheckResponseModel.fromJson(jsonResponse['data']);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> verifyCode({required String phoneNumber, required String code}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/code-verify');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'code': code}),
      );
      // REFACTOR: Panggil helper method, tidak perlu return apa-apa
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
  Future<void> createPin({required String phoneNumber, required String pin}) async {
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
  Future<UserModel> confirmPin({required String phone, required String confirmPin}) async {
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

  @override
  Future<String> loginAndGetToken({required String phoneNumber, required String pin}) async {
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
  Future<void> logout(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/logout');
    try {
      final response = await client.post(uri, headers: _headers(token: token));
      _processResponse(response);
    } on SocketException {
      throw const ServerException('Koneksi internet bermasalah');
    }
  }
  
  // Catatan: Metode `verifyPin` Anda sebelumnya duplikat dengan `loginAndGetToken`.
  // Sebaiknya hanya gunakan satu, yaitu `loginAndGetToken`.
  // Jika masih diperlukan, bisa diimplementasikan dengan pola yang sama.
}