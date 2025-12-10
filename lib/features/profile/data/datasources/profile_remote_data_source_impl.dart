import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl(this.client);

  // Helper method untuk check response status dan throw appropriate exception
  void _checkResponseStatus(
    http.Response response,
    Map<String, dynamic> jsonResponse,
  ) {
    if (response.statusCode == 401) {
      final message = jsonResponse['message'] ?? 'Unauthorized';
      if (message.toLowerCase().contains('token') &&
          (message.toLowerCase().contains('expired') ||
              message.toLowerCase().contains('invalid') ||
              message.toLowerCase().contains('not found'))) {
        throw AuthException(message, type: AuthErrorType.tokenExpired);
      }
      throw AuthException(message);
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(jsonResponse['message'] ?? 'Request failed');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required UserModel user,
    File? photoFile,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/update-profile');
    try {
      var request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['_method'] = 'PUT';
      request.fields['name'] = user.name;
      request.fields['gender'] = user.gender;

      if (user.dateOfBirth != null) {
        request.fields['date_of_birth'] = DateFormat(
          'yyyy-MM-dd',
        ).format(user.dateOfBirth!);
      }

      if (photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = json.decode(response.body);

      // debug: API Response (Update Profile): ${response.statusCode} -> $jsonResponse

      _checkResponseStatus(response, jsonResponse);

      final data = jsonResponse['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      // debug: Error updating user profile: $e
      throw const ServerException(
        'Failed to update profile due to server error.',
      );
    }
  }

  @override
  Future<void> createNewPin({
    required String newPin,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/new-pin-customer');
    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({'new_pin': newPin}),
      );

      final jsonResponse = json.decode(response.body);
      // debug: API Response (Create New PIN): ${response.statusCode} -> $jsonResponse

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to save new PIN',
        );
      }
    } catch (e) {
      // debug: Error creating new PIN: $e
      throw ServerException('Error creating new PIN: $e');
    }
  }

  @override
  Future<UserModel> confirmNewPin({
    required String confirmPin,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/confirm-new-pin-customer',
    );
    try {
      final response = await client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({'confirm_pin': confirmPin}),
      );

      final jsonResponse = json.decode(response.body);
      // debug: API Response (Confirm New PIN): ${response.statusCode} -> $jsonResponse
      if (response.statusCode == 200) {
        final data = jsonResponse['data'];
        return UserModel.fromJson(data);
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to confirm new PIN',
        );
      }
    } catch (e) {
      // debug: Error Confirming New PIN : $e
      throw ServerException('Error Confirming New PIN : $e');
    }
  }

  @override
  Future<void> requestChangePhone({
    required String newPhone,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/new-phone-customer');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode({'new_phone': newPhone}),
    );

    final jsonResponse = json.decode(response.body);
    // debug: API Response (Request Change Phone): ${response.statusCode} -> $jsonResponse

    if (response.statusCode == 200) {
      return;
    } else {
      throw ServerException(jsonResponse['message'] ?? 'Failed to request OTP');
    }
  }

  @override
  Future<void> verifyChangePhone({
    required String phone,
    required String code,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/verify-otp-customer',
    );
    final response = await client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode({'phone': phone, 'code': code}),
    );

    final jsonResponse = json.decode(response.body);
    // debug: API Response (Verify Change Phone): ${response.statusCode} -> $jsonResponse

    if (response.statusCode == 200) {
      return;
    } else {
      throw ServerException(jsonResponse['message'] ?? 'Failed to verify OTP');
    }
  }

  @override
  Future<void> verifyPin({required String pin, required String token}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/verify-pin');
    try {
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',

          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'pin': pin}),
      );

      final jsonResponse = json.decode(response.body);
      // debug: API Response (Verify PIN): ${response.statusCode} -> $jsonResponse

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          jsonResponse['message'] ?? 'Failed to verify PIN.',
        );
      }
    } catch (e) {
      // debug: Error verifying PIN: $e
      throw ServerException('An error occurred while verifying the PIN: $e');
    }
  }

  @override
  Future<void> logoutUser(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/auth/logout');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // debug: Successfully logged out from server.
    } else {
      // debug: Failed to logout from server: ${response.body}
    }
  }
}
