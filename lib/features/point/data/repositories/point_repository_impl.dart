import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/point/data/datasources/point_remote_datasource.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';
import 'package:nusantara_mobile/features/point/domain/repositories/point_repository.dart';

class PointRepositoryImpl implements PointRepository {
  final PointRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  PointRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, PointEntity>> getCustomerPoint() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDatasource.getCustomerPoint();
        return Right(result);
      } on ServerException catch (e) {
        print(
          "❌ PointRepository: ServerException in getCustomerPoint: ${e.message}",
        );
        return Left(ServerFailure(e.message));
      } catch (e) {
        print("💥 PointRepository: Unexpected error in getCustomerPoint: $e");
        return Left(
          ServerFailure('Gagal mendapatkan data point: ${e.toString()}'),
        );
      }
    } else {
      print("❌ PointRepository: No internet connection");
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failures, List<PointHistoryEntity>>>
  getCustomerPointHistory() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDatasource.getCustomerPointHistory();
        return Right(result);
      } on ServerException catch (e) {
        print(
          "❌ PointRepository: ServerException in getCustomerPointHistory: ${e.message}",
        );
        return Left(ServerFailure(e.message));
      } catch (e) {
        print(
          "💥 PointRepository: Unexpected error in getCustomerPointHistory: $e",
        );
        return Left(
          ServerFailure('Gagal mendapatkan riwayat point: ${e.toString()}'),
        );
      }
    } else {
      print("❌ PointRepository: No internet connection");
      return const Left(NetworkFailure('Tidak ada koneksi internet'));
    }
  }
}
