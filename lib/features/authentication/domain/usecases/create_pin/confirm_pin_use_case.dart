// features/authentication/domain/usecases/confirm_pin_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class ConfirmPinUseCase {
  final AuthRepository repository;

  ConfirmPinUseCase(this.repository);

  Future<Either<Failures, void>> call({
    required String phone,
    required String confirmPin,
  }) {
    return repository.confirmPin(phone: phone, confirmPin: confirmPin);
  }
}
