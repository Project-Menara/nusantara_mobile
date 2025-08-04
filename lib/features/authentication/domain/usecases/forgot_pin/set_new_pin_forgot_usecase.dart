import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class SetNewPinForgotUseCase implements Usecase<void, SetNewPinForgotParams> {
  final AuthRepository repository;

  SetNewPinForgotUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(SetNewPinForgotParams params) async {
    return await repository.setNewPinForgot(
      token: params.token,
      phoneNumber: params.phoneNumber,
      pin: params.pin,
    );
  }
}

class SetNewPinForgotParams extends Equatable {
  final String token;
  final String phoneNumber;
  final String pin;

  const SetNewPinForgotParams({
    required this.token,
    required this.phoneNumber,
    required this.pin,
  });

  @override
  List<Object?> get props => [token, phoneNumber, pin];
}