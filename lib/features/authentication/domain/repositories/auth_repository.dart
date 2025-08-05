import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(String phoneNumber);
  Future<Either<Failures, Unit>> resendCode(String phoneNumber);
  Future<Either<Failures, String>> forgotPin(String phoneNumber);

  // <<< TAMBAHAN UNTUK VALIDASI TOKEN LUPA PIN >>>
  Future<Either<Failures, void>> validateForgotPinToken(String token);

  Future<Either<Failures, Unit>> verifyCode({
    required String phoneNumber,
    required String code,
  });

  Future<Either<Failures, RegisterResponseModel>> register(RegisterEntity user);

  Future<Either<Failures, Unit>> createPin({
    required String phoneNumber,
    required String pin,
  });

  Future<Either<Failures, UserEntity>> confirmPin({
    required String phone,
    required String confirmPin,
  });

  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  });
  
  Future<Either<Failures, UserEntity>> getLoggedInUser();
  
  Future<Either<Failures, void>> setNewPinForgot({
    required String token,
    required String phoneNumber,
    required String pin,
  });

  Future<Either<Failures, UserEntity>> confirmNewPinForgot({
    required String token,
    required String phoneNumber,
    required String confirmPin,
  });

  Future<Either<Failures, Unit>> logout();
}