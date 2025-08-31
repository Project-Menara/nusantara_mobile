import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';

class ClaimVoucherUsecase implements Usecase<ClaimedVoucherEntity, String> {
  final VoucherRepository repository;

  ClaimVoucherUsecase(this.repository);

  @override
  Future<Either<Failures, ClaimedVoucherEntity>> call(String voucherId) async {
    print("🎫 ClaimVoucherUsecase: Claiming voucher with ID: $voucherId");

    try {
      final result = await repository.claimVoucher(voucherId);

      return result.fold(
        (failure) {
          print(
            "❌ ClaimVoucherUsecase: Failed to claim voucher: ${failure.message}",
          );
          return Left(failure);
        },
        (claimedVoucher) {
          print(
            "✅ ClaimVoucherUsecase: Successfully claimed voucher: ${claimedVoucher.voucher.code}",
          );
          return Right(claimedVoucher);
        },
      );
    } catch (e) {
      print("💥 ClaimVoucherUsecase: Exception occurred: $e");
      return Left(ServerFailure('Failed to claim voucher: $e'));
    }
  }
}
