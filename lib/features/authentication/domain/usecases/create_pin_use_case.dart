import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class CreatePinUseCase {
  final AuthRepository repository;

  CreatePinUseCase(this.repository);

  /// 'call' akan menjadi satu-satunya fungsi publik di kelas ini.
  /// Ini menjalankan tugas spesifik: membuat PIN.
  Future<Either<Failures, Unit>> call({
    required String phoneNumber,
    required String pin,
  }) async {
    // Meneruskan tugas ke lapisan repository
    return await repository.createPin(phoneNumber: phoneNumber, pin: pin);
  }
}
