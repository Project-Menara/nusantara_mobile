import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class VerifyCodeUseCase {
  final AuthRepository repository;

  VerifyCodeUseCase(this.repository);

  /// Menjalankan tugas verifikasi kode OTP
  Future<Either<Failures, Unit>> call({
    required String phoneNumber,
    required String code,
  }) async {
    return await repository.verifyCode(phoneNumber: phoneNumber, code: code);
  }
}
