import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class ResendCodeUseCase implements Usecase<void, String> {
  final AuthRepository repository;

  ResendCodeUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(String phoneNumber) async {
    return await repository.resendCode(phoneNumber);
  }
}