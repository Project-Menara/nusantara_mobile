import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalDatasource localDatasource;

  ShopRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.localDatasource,
  });

  @override
  Future<Either<Failures, List<ShopEntity>>> getNearbyShops({
    required double lat,
    required double lng,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Decide to use public endpoint if no auth token exists
        final token = await localDatasource.getAuthToken();
        final result = await remoteDataSource.getNearbyShops(
          lat: lat,
          lng: lng,
          public: token == null,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failures, ShopEntity>> getShopDetail({
    required String shopId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getShopDetail(shopId: shopId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
