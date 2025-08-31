import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/voucher/data/datasources/voucher_remote_data_source.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource voucherRemoteDataSource;
  final NetworkInfo networkInfo;

  VoucherRepositoryImpl({
    required this.voucherRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<VoucherEntity>>> getVouchers() async {
    print("🌐 VoucherRepository: Starting getVouchers()");
    print("🌐 VoucherRepository: Checking network connection...");

    try {
      final isConnected = await networkInfo.isConnected;
      print("🌐 VoucherRepository: Network connected: $isConnected");

      // 1. Cek koneksi internet
      if (isConnected) {
        print(
          "✅ VoucherRepository: Network connected, fetching vouchers from API...",
        );
        try {
          // 2. Jika terkoneksi, panggil data source untuk mengambil data dari API
          print("🌐 VoucherRepository: Calling remote data source...");
          final vouchers = await voucherRemoteDataSource.getVouchers();
          print(
            "✅ VoucherRepository: Successfully got ${vouchers.length} vouchers from remote data source",
          );
          // 3. Jika berhasil, kembalikan data yang dibungkus dengan `Right`
          return Right(vouchers);
        } on ServerException catch (e) {
          print("❌ VoucherRepository: Server exception occurred: ${e.message}");
          // 4. Jika terjadi error dari server, kembalikan `Left` dengan `ServerFailure`
          return Left(ServerFailure(e.message));
        } catch (e) {
          print("❌ VoucherRepository: Unexpected error occurred: $e");
          return Left(ServerFailure('Unexpected error: $e'));
        }
      } else {
        print("❌ VoucherRepository: Network not connected");
        // 5. Jika tidak ada koneksi, kembalikan `Left` dengan `NetworkFailure`
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }
    } catch (e) {
      print("💥 VoucherRepository: Exception in getVouchers: $e");
      return Left(ServerFailure('Error checking network: $e'));
    }
  }

  @override
  Future<Either<Failures, VoucherEntity>> getVoucherById(String id) async {
    // Pola yang sama diterapkan untuk getVoucherById
    if (await networkInfo.isConnected) {
      try {
        final voucher = await voucherRemoteDataSource.getVoucherById(id);
        return Right(voucher);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failures, ClaimedVoucherEntity>> claimVoucher(
    String voucherId,
  ) async {
    print(
      "🎯 VoucherRepository: Starting claimVoucher() for voucher ID: $voucherId",
    );
    print("🌐 VoucherRepository: Checking network connection...");

    try {
      final isConnected = await networkInfo.isConnected;
      print("🌐 VoucherRepository: Network connected: $isConnected");

      // 1. Cek koneksi internet
      if (isConnected) {
        print(
          "✅ VoucherRepository: Network connected, claiming voucher from API...",
        );
        try {
          // 2. Jika terkoneksi, panggil data source untuk claim voucher
          print(
            "🎯 VoucherRepository: Calling remote data source to claim voucher...",
          );
          final claimedVoucher = await voucherRemoteDataSource.claimVoucher(
            voucherId,
          );
          print(
            "✅ VoucherRepository: Successfully claimed voucher: ${claimedVoucher.id}",
          );
          // 3. Jika berhasil, kembalikan data yang dibungkus dengan `Right`
          return Right(claimedVoucher);
        } on ServerException catch (e) {
          print(
            "❌ VoucherRepository: Server exception occurred while claiming voucher: ${e.message}",
          );
          // 4. Jika terjadi error dari server, kembalikan `Left` dengan `ServerFailure`
          return Left(ServerFailure(e.message));
        } catch (e) {
          print(
            "❌ VoucherRepository: Unexpected error occurred while claiming voucher: $e",
          );
          return Left(ServerFailure('Unexpected error: $e'));
        }
      } else {
        print("❌ VoucherRepository: Network not connected");
        // 5. Jika tidak ada koneksi, kembalikan `Left` dengan `NetworkFailure`
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }
    } catch (e) {
      print("💥 VoucherRepository: Exception in claimVoucher: $e");
      return Left(ServerFailure('Error checking network: $e'));
    }
  }

  @override
  Future<Either<Failures, List<ClaimedVoucherEntity>>>
  getClaimedVouchers() async {
    print("🎟️ VoucherRepository: Starting getClaimedVouchers()");
    print("🌐 VoucherRepository: Checking network connection...");

    try {
      final isConnected = await networkInfo.isConnected;
      print("🌐 VoucherRepository: Network connected: $isConnected");

      // 1. Cek koneksi internet
      if (isConnected) {
        print(
          "✅ VoucherRepository: Network connected, fetching claimed vouchers from API...",
        );
        try {
          // 2. Jika terkoneksi, panggil data source untuk mengambil data dari API
          print(
            "🎟️ VoucherRepository: Calling remote data source to get claimed vouchers...",
          );
          final claimedVouchers = await voucherRemoteDataSource
              .getClaimedVouchers();
          print(
            "✅ VoucherRepository: Successfully got ${claimedVouchers.length} claimed vouchers from remote data source",
          );
          // 3. Jika berhasil, kembalikan data yang dibungkus dengan `Right`
          return Right(claimedVouchers);
        } on ServerException catch (e) {
          print(
            "❌ VoucherRepository: Server exception occurred while getting claimed vouchers: ${e.message}",
          );
          // 4. Jika terjadi error dari server, kembalikan `Left` dengan `ServerFailure`
          return Left(ServerFailure(e.message));
        } catch (e) {
          print(
            "❌ VoucherRepository: Unexpected error occurred while getting claimed vouchers: $e",
          );
          return Left(ServerFailure('Unexpected error: $e'));
        }
      } else {
        print("❌ VoucherRepository: Network not connected");
        // 5. Jika tidak ada koneksi, kembalikan `Left` dengan `NetworkFailure`
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }
    } catch (e) {
      print("💥 VoucherRepository: Exception in getClaimedVouchers: $e");
      return Left(ServerFailure('Error checking network: $e'));
    }
  }
}
