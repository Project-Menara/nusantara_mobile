import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';

class RequestChangePhoneUseCase implements Usecase<void, RequestChangePhoneParams> {
  final ProfileRepository repository;

  RequestChangePhoneUseCase(this.repository);

  @override
  Future<Either<Failures, void>> call(RequestChangePhoneParams params) async {
    return await repository.requestChangePhone(params.newPhone);
  }
}

class RequestChangePhoneParams extends Equatable {
  final String newPhone;

  const RequestChangePhoneParams({required this.newPhone});

  @override
  List<Object?> get props => [newPhone];
}