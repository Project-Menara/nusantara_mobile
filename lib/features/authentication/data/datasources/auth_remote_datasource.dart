import 'dart:convert';
import 'dart:io'; // Diperlukan untuk SocketException

import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';

// Asumsi Anda memiliki file-file ini
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String name, String username, String email, String password, String confirmationPassword);
  Future<UserModel> getUser(String token);
  Future<String> logout(String token);
}


class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;

  AuthRemoteDatasourceImpl(this.client);

  // Helper untuk membuat headers, mengurangi redundansi
  Map<String, String> _headers({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<UserModel> login(String username, String password) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/login');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        // Melempar exception yang sesuai dari server
        throw AuthException(jsonResponse['message'] ?? 'Login failed');
      }
    } on SocketException {
      // Menangani error koneksi internet
      throw const ServerException('No Internet Connection');
    } catch (e) {
      // Menangkap error lain yang tidak terduga
      throw ServerException(e.toString());
    }
  }
  
  @override
  Future<UserModel> register(
    String name,
    String username,
    String email,
    String password,
    String confirmationPassword,
  ) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/register');
    try {
      final response = await client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({
          'username': username,
          'name': name,
          'email': email,
          'password': password,
          'confirmation_password': confirmationPassword,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return UserModel.fromUserJson(jsonResponse['data']);
      } else {
        // Asumsi server memberikan pesan error yang jelas
        throw ServerException(jsonResponse['message'] ?? 'Registration failed');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getUser(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/me');
    try {
      final response = await client.get(
        uri,
        headers: _headers(token: token),
      );
      
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromUserJson(jsonResponse['data']);
      } else {
        throw AuthException(jsonResponse['message'] ?? 'Failed to get user');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> logout(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/logout');
    try {
      final response = await client.post(
        uri,
        headers: _headers(token: token),
      );
      
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse['message'];
      } else {
        throw ServerException(jsonResponse['message'] ?? 'Logout failed');
      }
    } on SocketException {
      throw const ServerException('No Internet Connection');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}