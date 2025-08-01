import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

// --- PERUBAHAN: Ganti Usecase<Unit, String> menjadi Usecase<void, String> ---
class ResendCodeUseCase implements Usecase<void, String> {
  final AuthRepository repository;

  ResendCodeUseCase(this.repository);

  @override
  // --- PERUBAHAN: Ganti return type Future<...> menjadi void ---
  Future<Either<Failures, void>> call(String phoneNumber) async {
    return await repository.resendCode(phoneNumber);
  }
}