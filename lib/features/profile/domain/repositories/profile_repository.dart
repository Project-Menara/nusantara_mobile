import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failures, UserEntity>> updateUserProfile(
    UserEntity user,
    File? photoFile,
  );
  Future<Either<Failures, void>> logoutUser();
  Future<Either<Failures, void>> createNewPin(String newPin);
  Future<Either<Failures, UserEntity>> confirmNewPin(String confirmPin);
}
