import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';

abstract class VoucherRepository {
  Future<Either<Failures, List<VoucherEntity>>> getVouchers();
  Future<Either<Failures, VoucherEntity>> getVoucherById(String id);
  Future<Either<Failures, ClaimedVoucherEntity>> claimVoucher(String voucherId);
  Future<Either<Failures, List<ClaimedVoucherEntity>>> getClaimedVouchers();
}
