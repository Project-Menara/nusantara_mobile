// lib/features/authentication/data/datasources/auth_remote_datasource.dart

import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber);

  Future<void> verifyCode({required String phoneNumber, required String code});

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  });

  Future<void> createPin({required String phoneNumber, required String pin});

  // PERBAIKAN: Ubah return type dari Future<void> menjadi Future<UserModel>
  Future<UserModel> confirmPin({
    required String phone,
    required String confirmPin,
  });

  Future<UserModel> verifyPin({
    required String phoneNumber,
    required String pin,
  });
  Future<String> loginAndGetToken({
    required String phoneNumber,
    required String pin,
  });

  Future<UserModel> getUserProfile({required String token});

  Future<void> logout(String token);
}
