import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';

class GetClaimedVouchersUsecase
    implements Usecase<List<ClaimedVoucherEntity>, NoParams> {
  final VoucherRepository repository;

  GetClaimedVouchersUsecase(this.repository);

  @override
  Future<Either<Failures, List<ClaimedVoucherEntity>>> call(
    NoParams params,
  ) async {
    print("🎫 GetClaimedVouchersUsecase: Fetching claimed vouchers");

    try {
      final result = await repository.getClaimedVouchers();

      return result.fold(
        (failure) {
          print(
            "❌ GetClaimedVouchersUsecase: Failed to fetch claimed vouchers: ${failure.message}",
          );
          return Left(failure);
        },
        (claimedVouchers) {
          print(
            "✅ GetClaimedVouchersUsecase: Successfully fetched ${claimedVouchers.length} claimed vouchers",
          );
          return Right(claimedVouchers);
        },
      );
    } catch (e) {
      print("💥 GetClaimedVouchersUsecase: Exception occurred: $e");
      return Left(ServerFailure('Failed to fetch claimed vouchers: $e'));
    }
  }
}
