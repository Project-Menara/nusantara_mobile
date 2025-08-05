import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

/// Use case ini mengimplementasikan Usecase generik.
/// Tipe kembalian suksesnya adalah `Unit` (karena tidak ada data spesifik, dari dartz).
/// Tipe parameternya adalah `ValidateForgotPinTokenParams`.
class ValidateForgotPinTokenUseCase implements Usecase<Unit, ValidateForgotPinTokenParams> {
  final AuthRepository repository;

  ValidateForgotPinTokenUseCase(this.repository);

  @override
  Future<Either<Failures, Unit>> call(ValidateForgotPinTokenParams params) async {
    final result = await repository.validateForgotPinToken(params.token);
    return result.map((_) => unit);
  }
}

/// Class khusus untuk menampung parameter yang dibutuhkan oleh use case.
/// Meng-extend Equatable agar mudah dibandingkan.
class ValidateForgotPinTokenParams extends Equatable {
  final String token;

  const ValidateForgotPinTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}