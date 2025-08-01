// lib/features/profile/data/datasources/profile_remote_data_source.dart
import 'package:nusantara_mobile/features/profile/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<UserModel>> getUserProfiles(String token);
  Future<UserModel> updateUserProfile(UserModel user, String token);
  Future<void> logoutUser(String token);
}