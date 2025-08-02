// lib/features/authentication/data/datasources/auth_remote_datasource.dart

import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber);
  Future<void> verifyCode({required String phoneNumber, required String code});
  Future<RegisterResponseModel> register(RegisterModel register);
  Future<void> createPin({required String phoneNumber, required String pin});
  Future<void> resendCode(String phoneNumber);
  Future<String> forgotPin(String phoneNumber);
  Future<void> setNewPinForgot({
    required String token,
    required String phoneNumber,
    required String pin,
  });

  Future<UserModel> confirmNewPinForgot({
    required String token,
    required String phoneNumber,
    required String confirmPin,
  });

  Future<UserModel> confirmPin({
    required String phone,
    required String confirmPin,
  });

  Future<String> loginAndGetToken({
    required String phoneNumber,
    required String pin,
  });
  Future<UserModel> getUserProfile({required String token});

  Future<void> logout(String token);
}
