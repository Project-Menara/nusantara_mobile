import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failures, List<UserEntity>>> getUserProfiles();
}
