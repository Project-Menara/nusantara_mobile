import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

// Gunakan Usecase<void, ...> karena verifikasi OTP tidak mengembalikan data
class VerifyCodeUseCase extends Usecase<void, VerifyCodeParams> {
  final AuthRepository repository;

  VerifyCodeUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(VerifyCodeParams params) async {
    return await repository.verifyCode(
      phoneNumber: params.phoneNumber,
      code: params.code,
    );
  }
}

// DEFINISIKAN KELAS PARAMETER DI SINI
class VerifyCodeParams extends Equatable {
  final String phoneNumber;
  final String code;

  const VerifyCodeParams({required this.phoneNumber, required this.code});

  @override
  List<Object?> get props => [phoneNumber, code];
}
