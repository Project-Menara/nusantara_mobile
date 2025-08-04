import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase
    implements Usecase<RegisterResponseModel, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failures, RegisterResponseModel>> call(
    RegisterParams params,
  ) async {
    return await repository.register(params.registerEntity);
  }
}

class RegisterParams extends Equatable {
  final RegisterEntity registerEntity;

  const RegisterParams({required this.registerEntity});

  @override
  List<Object?> get props => [registerEntity];
}
