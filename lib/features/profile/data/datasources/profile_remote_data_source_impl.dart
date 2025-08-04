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

  @override
  Future<UserModel> updateUserProfile({
    required UserModel user,
    File? photoFile,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/update-profile');
    var request = http.MultipartRequest('PUT', uri); // Disarankan POST untuk method spoofing

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['_method'] = 'PUT';
    request.fields['name'] = user.name;
    request.fields['gender'] = user.gender;

    if (user.dateOfBirth != null) {
      request.fields['date_of_birth'] =
          DateFormat('yyyy-MM-dd').format(user.dateOfBirth!);
    }

    if (photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final jsonResponse = json.decode(response.body);

    print(
      "API Response (Update Profile): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse['data']);
    } else {
      throw ServerException(
        jsonResponse['message'] ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<void> createNewPin({
    required String newPin,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/new-pin-customer');
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
    print(
      "API Response (Create New PIN): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode != 200) {
      throw ServerException(
        jsonResponse['message'] ?? 'Failed to save new PIN',
      );
    }
  }

  @override
  Future<UserModel> confirmNewPin({
    required String confirmPin,
    required String token,
  }) async {
    final uri =
        Uri.parse('${ApiConstant.baseUrl}/customer/confirm-new-pin-customer');
    final response = await client.put( // Disarankan menggunakan POST
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode({'confirm_pin': confirmPin}),
    );

    final jsonResponse = json.decode(response.body);
    print(
      "API Response (Confirm New PIN): ${response.statusCode} -> $jsonResponse",
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse['data']);
    } else {
      throw ServerException(
        jsonResponse['message'] ?? 'Failed to confirm new PIN',
      );
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

    // <<< PERBAIKAN: Tambahkan print response >>>
    final jsonResponse = json.decode(response.body);
    print(
      "API Response (Request Change Phone): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode != 200) {
      throw ServerException(jsonResponse['message'] ?? 'Failed to request OTP');
    }
  }

  @override
  Future<void> verifyChangePhone({
    required String phone,
    required String code,
    required String token,
  }) async {
    final uri =
        Uri.parse('${ApiConstant.baseUrl}/customer/verify-otp-customer');
    final response = await client.put( // Disarankan menggunakan POST
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode({'phone': phone, 'code': code}),
    );

    // <<< PERBAIKAN: Tambahkan print response >>>
    final jsonResponse = json.decode(response.body);
    print(
      "API Response (Verify Change Phone): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode != 200) {
      throw ServerException(jsonResponse['message'] ?? 'Failed to verify OTP');
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

    if (response.statusCode != 200) {
      print('Failed to logout from server: ${response.body}');
    }
  }
}