import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class VerifyPinAndLoginUseCase {
  final AuthRepository repository;

  VerifyPinAndLoginUseCase(this.repository);

  // 'call' akan menerima parameter dan mengembalikan data User
  // Future<Either<Failures, UserEntity>> call(VerifyPinParams params) async {
  //   return await repository.verifyPinAndLogin(
  //     phoneNumber: params.phoneNumber,
  //     pin: params.pin,
  //   );
  // }
}

// Kelas untuk membungkus parameter agar lebih rapi
class VerifyPinParams extends Equatable {
  final String phoneNumber;
  final String pin;

  const VerifyPinParams({required this.phoneNumber, required this.pin});

  @override
  List<Object?> get props => [phoneNumber, pin];
}