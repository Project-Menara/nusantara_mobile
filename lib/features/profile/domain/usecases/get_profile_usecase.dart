import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class GetProfile extends Usecase<List<UserEntity>, NoParams> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failures, List<UserEntity>>> call(NoParams params) async {
    return repository.getUserProfiles();
  }
}
