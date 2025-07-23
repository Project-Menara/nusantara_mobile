// features/authentication/domain/usecases/register_usecase.dart
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
  }) {
    return repository.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
    );
  }
}