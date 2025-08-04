import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class CreateNewPinUseCase implements Usecase<void, CreatePinParams> {
  final ProfileRepository repository;

  CreateNewPinUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(CreatePinParams params) async {
    return await repository.createNewPin(params.newPin);
  }
}

class CreatePinParams extends Equatable {
  final String newPin;

  const CreatePinParams({required this.newPin});

  @override
  List<Object?> get props => [newPin];
}