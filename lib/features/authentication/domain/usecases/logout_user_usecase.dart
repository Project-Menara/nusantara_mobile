import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class LogoutUserUseCase implements Usecase<void, NoParams> {
  final ProfileRepository repository;

  LogoutUserUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(NoParams params) async {
    // Panggil metode logout dari repository
    return await repository.logoutUser();
  }
}