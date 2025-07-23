import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(
    String name,
    String username,
    String email,
    String password,
    String confirmationPassword,
  );
  Future<UserModel> getUser(String token);
  Future<void> logout(String token);
}