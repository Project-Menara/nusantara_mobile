import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class ForgotPinUseCase implements Usecase<String, String> {
  final AuthRepository repository;

  ForgotPinUseCase(this.repository);

  @override
  Future<Either<Failures, String>> call(String phoneNumber) async {
    return await repository.forgotPin(phoneNumber);
  }
}
