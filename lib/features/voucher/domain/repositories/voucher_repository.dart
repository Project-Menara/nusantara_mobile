import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';

abstract class VoucherRepository {
  Future<Either<Failures, List<VoucherEntity>>> getVouchers();
  Future<Either<Failures, VoucherEntity>> getVoucherById(String id);
}