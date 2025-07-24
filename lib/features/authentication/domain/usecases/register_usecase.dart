import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  // 'call' akan mengembalikan Future<Either<Failure, Unit>>
  Future<Either<Failures, Unit>> call(RegisterParams params) {
    return repository.register(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      gender: params.gender,
      pin: params.pin, // pin ditambahkan
    );
  }
}

// Kelas untuk membungkus parameter registrasi
class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String pin;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.pin,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, gender, pin];
}
