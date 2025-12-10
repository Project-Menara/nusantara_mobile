import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';

class GetAllVoucherUsecase implements Usecase<List<VoucherEntity>, NoParams> {
  final VoucherRepository voucherRepository;

  GetAllVoucherUsecase(this.voucherRepository);

  @override
  Future<Either<Failures, List<VoucherEntity>>> call(NoParams params) async {
    // debug: 🎯 GetAllVoucherUsecase: Calling repository.getVouchers()
    final result = await voucherRepository.getVouchers();
    result.fold(
      (failure) => // debug: ❌ GetAllVoucherUsecase: Failed with: $failure
          null,
      (
        vouchers,
      ) => // debug: ✅ GetAllVoucherUsecase: Success with ${vouchers.length} vouchers
          null,
    );
    return result;
  }
}
