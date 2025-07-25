import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  // NetworkInfo networkInfo, PERBAIKAN: Constructor disederhanakan.
  AuthRemoteDataSourceImpl(NetworkInfo networkInfo, {required this.client});

  // Helper untuk membuat headers, mengurangi duplikasi
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
            json.decode(response.body)['message'] ?? 'Failed to check phone');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  // PENAMBAHAN: Implementasi untuk verifikasi kode OTP
  @override
  Future<void> verifyCode({required String phoneNumber, required String code}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/code-verify');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'code': code}),
      );

      // Berdasarkan screenshot, 200 adalah sukses
      if (response.statusCode != 200) {
        throw ServerException(
            json.decode(response.body)['message'] ?? 'OTP Verification Failed');
      }
      // Tidak perlu return apa-apa jika sukses
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<void> register(
      {required String name,
      required String username,
      required String email,
      required String phone,
      required String gender}) async {
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
            json.decode(response.body)['message'] ?? 'Registration failed');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  // PENAMBAHAN: Implementasi untuk membuat PIN baru
  @override
  Future<void> createPin({required String phoneNumber, required String pin}) async {
    // ASUMSI: Endpointnya adalah /customer/new-pin
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/new-pin');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );
      if (response.statusCode != 200) {
        throw ServerException(
            json.decode(response.body)['message'] ?? 'Failed to create PIN');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<UserModel> verifyPin(
      {required String phoneNumber, required String pin}) async {
    // Ganti nama endpoint agar lebih jelas
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/login');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        // Asumsi API mengembalikan data user di dalam field 'data'
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        throw AuthException(
            jsonResponse['message'] ?? 'Invalid PIN or phone number');
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
            json.decode(response.body)['message'] ?? 'Logout failed');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }
}