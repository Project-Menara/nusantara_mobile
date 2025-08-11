import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/voucher/data/datasources/voucher_remote_data_source.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
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
    // 1. Cek koneksi internet
    if (await networkInfo.isConnected) {
      try {
        // 2. Jika terkoneksi, panggil data source untuk mengambil data dari API
        final vouchers = await voucherRemoteDataSource.getVouchers();
        // 3. Jika berhasil, kembalikan data yang dibungkus dengan `Right`
        return Right(vouchers);
      } on ServerException catch (e) {
        // 4. Jika terjadi error dari server, kembalikan `Left` dengan `ServerFailure`
        return Left(ServerFailure(e.message));
      }
    } else {
      // 5. Jika tidak ada koneksi, kembalikan `Left` dengan `NetworkFailure`
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
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
}