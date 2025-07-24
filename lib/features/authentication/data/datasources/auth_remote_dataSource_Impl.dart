import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart'; // Pastikan path ini benar
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

// Kontrak/Interface yang sudah Anda buat
// abstract class AuthRemoteDataSource {
//   Future<PhoneCheckResponseModel> checkPhone(String phoneNumber);
//   Future<UserModel> verifyPin({
//     required String phoneNumber,
//     required String pin,
//   });
//   Future<void> register({
//     required String fullName,
//     required String email,
//     required String phoneNumber,
//     required String gender,
//     required String pin,
//   });
//   Future<void> logout(String token);
// }

// Implementasi konkret dari kontrak di atas
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(Object object, {required this.client});

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
    // ASUMSI: Endpoint sesuai dengan Postman Anda
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
          json.decode(response.body)['message'] ??
              'Failed to check phone number',
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
    // ASUMSI: Endpoint untuk verifikasi pin
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/verify-pin');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone': phoneNumber, 'pin': pin}),
      );

      final jsonResponse = json.decode(response.body);

      // 200 OK untuk login sukses
      if (response.statusCode == 200) {
        // Asumsi API mengembalikan data user dan token
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        // Jika PIN salah atau error lain, lempar AuthException
        throw AuthException(
          jsonResponse['message'] ?? 'Invalid PIN or phone number',
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

      // 201 Created biasanya untuk sukses membuat data baru
      if (response.statusCode != 201) {
        // Jika gagal (misal: email sudah terdaftar), lempar ServerException
        throw ServerException(
          json.decode(response.body)['message'] ?? 'Registration failed',
        );
      }
      // Tidak perlu return apa-apa jika sukses (Future<void>)
    } on SocketException {
      throw const ServerException('No Internet Connection');
    }
  }

  @override
  Future<void> logout(String token) async {
    // ASUMSI: Endpoint untuk logout
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
}
