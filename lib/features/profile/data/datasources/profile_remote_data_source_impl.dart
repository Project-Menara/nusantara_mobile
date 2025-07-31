import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/data/models/user_model.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';

class ProfileRemoteDataSourceImpl extends ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<List<UserModel>> getUserProfiles(String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/me');
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("User Data : ${jsonResponse}");
      final List<dynamic> data = jsonResponse['data'];
      final users = data.map((json) => UserModel.fromJson(json)).toList();
      return users;
    } else {
      throw ServerException('Failed to load users');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user, String token) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/me');
    final response = await client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("User Data : ${jsonResponse}");
      final dynamic data = jsonResponse['data'];
      final updatedUser = UserModel.fromJson(data);
      return updatedUser;
    } else {
      throw ServerException('Failed to load user');
    }
  }
}
