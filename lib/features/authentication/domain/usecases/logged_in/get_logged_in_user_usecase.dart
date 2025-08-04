import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class GetLoggedInUserUseCase implements Usecase<UserEntity, NoParams> {
  final AuthRepository repository;

  GetLoggedInUserUseCase(this.repository);

  @override
  Future<Either<Failures, UserEntity>> call(NoParams params) async {
    return await repository.getLoggedInUser();
  }
}
