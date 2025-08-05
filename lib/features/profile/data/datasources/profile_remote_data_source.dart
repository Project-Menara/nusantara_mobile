import 'dart:io';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> updateUserProfile({
    required UserModel user,
    File? photoFile,
    required String token,
  });
  Future<void> logoutUser(String token);
  Future<void> createNewPin({required String newPin, required String token});

  Future<UserModel> confirmNewPin({
    required String confirmPin,
    required String token,
  });
  Future<void> requestChangePhone({
    required String newPhone,
    required String token,
  });

  Future<void> verifyChangePhone({
    required String phone,
    required String code,
    required String token,
  });
  Future<void> verifyPin({required String pin, required String token});
}
