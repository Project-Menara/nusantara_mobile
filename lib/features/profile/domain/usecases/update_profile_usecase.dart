import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile extends Usecase<UserEntity, UserEntity> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failures, UserEntity>> call(UserEntity params) {
    return repository.updateUserProfile(params);
  }
}
