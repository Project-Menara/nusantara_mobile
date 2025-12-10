import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class CreatePinUseCase {
  final AuthRepository repository;
  CreatePinUseCase(this.repository);

  Future<Either<Failures, Unit>> call({
    // Ganti UserEntity menjadi Unit
    required String phoneNumber,
    required String pin,
  }) async {
    return await repository.createPin(phoneNumber: phoneNumber, pin: pin);
  }
}
