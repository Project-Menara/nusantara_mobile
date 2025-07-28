import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failures, Unit>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      username: params.username,
      email: params.email,
      phone: params.phone,
      gender: params.gender,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;

  const RegisterParams({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
  });

  @override
  List<Object?> get props => [name, username, email, phone, gender];
}
