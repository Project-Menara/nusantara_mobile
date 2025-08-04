import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class ConfirmNewPinForgotUseCase implements Usecase<UserEntity, ConfirmNewPinForgotParams> {
  final AuthRepository repository;

  ConfirmNewPinForgotUseCase(this.repository);

  @override
  Future<Either<Failures, UserEntity>> call(ConfirmNewPinForgotParams params) async {
    return await repository.confirmNewPinForgot(
      token: params.token,
      phoneNumber: params.phoneNumber,
      confirmPin: params.confirmPin,
    );
  }
}

class ConfirmNewPinForgotParams extends Equatable {
  final String token;
  final String phoneNumber;
  final String confirmPin;

  const ConfirmNewPinForgotParams({
    required this.token,
    required this.phoneNumber,
    required this.confirmPin,
  });

  @override
  List<Object?> get props => [token, phoneNumber, confirmPin];
}