import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';

class CheckPhoneUseCase {
  final AuthRepository repository;

  CheckPhoneUseCase(this.repository);

  // 'call' akan menerima nomor telepon dan mengembalikan hasil pengecekan
  Future<Either<Failures, PhoneCheckEntity>> call(String phoneNumber) async {
    return await repository.checkPhone(phoneNumber);
  }
}
