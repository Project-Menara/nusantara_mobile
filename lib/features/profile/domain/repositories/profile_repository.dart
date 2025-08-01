// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failures, List<UserEntity>>> getUserProfiles();
  Future<Either<Failures, UserEntity>> updateUserProfile(UserEntity user);
  Future<Either<Failures, void>> logoutUser(); 
}