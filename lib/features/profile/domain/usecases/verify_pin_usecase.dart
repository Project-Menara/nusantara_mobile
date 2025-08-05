import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart'; 
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class VerifyPinUsecase implements Usecase<void, VerifyPinParams> {
  final ProfileRepository repository;

  VerifyPinUsecase(this.repository);

  /// Memanggil metode [verifyPin] dari repository.
  @override
  Future<Either<Failures, void>> call(VerifyPinParams params) async {
    return await repository.verifyPin(params.pin);
  }
}

class VerifyPinParams extends Equatable {
  final String pin;

  const VerifyPinParams({required this.pin});

  @override
  List<Object?> get props => [pin];
}
