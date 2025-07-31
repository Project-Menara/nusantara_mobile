import 'package:nusantara_mobile/features/profile/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<UserModel>> getUserProfiles(String token);
  Future<UserModel> updateUserProfile(UserModel user, String token);
}
