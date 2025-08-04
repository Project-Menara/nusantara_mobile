import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class VerifyChangePhoneUseCase implements Usecase<void, VerifyChangePhoneParams> {
  final ProfileRepository repository;

  VerifyChangePhoneUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(VerifyChangePhoneParams params) async {
    return await repository.verifyChangePhone(phone: params.phone, code: params.code);
  }
}

class VerifyChangePhoneParams extends Equatable {
  final String phone;
  final String code;

  const VerifyChangePhoneParams({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}