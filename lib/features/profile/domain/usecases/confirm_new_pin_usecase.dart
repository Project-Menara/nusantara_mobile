import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class ConfirmNewPinUseCase implements Usecase<UserEntity, ConfirmPinParams> {
  final ProfileRepository repository;

  ConfirmNewPinUseCase(this.repository);

  @override
  Future<Either<Failures, UserEntity>> call(ConfirmPinParams params) async {
    return await repository.confirmNewPin(params.confirmPin);
  }
}

class ConfirmPinParams extends Equatable {
  final String confirmPin;

  const ConfirmPinParams({required this.confirmPin});

  @override
  List<Object?> get props => [confirmPin];
}