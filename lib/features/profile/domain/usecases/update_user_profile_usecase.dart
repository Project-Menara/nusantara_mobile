import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfileUseCase
    implements Usecase<UserEntity, UpdateUserParams> {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failures, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUserProfile(params.user, params.photoFile);
  }
}

class UpdateUserParams extends Equatable {
  final UserEntity user;
  final File? photoFile;

  const UpdateUserParams({required this.user, this.photoFile});

  @override
  List<Object?> get props => [user, photoFile];
}
