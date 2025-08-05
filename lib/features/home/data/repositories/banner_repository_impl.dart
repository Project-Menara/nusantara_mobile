import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/home/data/dataSource/banner_remote_dataSource.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDatasource bannerRemoteDatasource;
  final NetworkInfo networkInfo;

  BannerRepositoryImpl({
    required this.bannerRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<BannerEntity>>> getBanners() async {
    if (await networkInfo.isConnected) {
      try {
        final banners = await bannerRemoteDatasource.getBanners();
        return Right(banners);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, BannerEntity>> getBannerById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final banner = await bannerRemoteDatasource.getBannerById(id);
        return Right(banner);
      } catch (e) {
        throw Left(e.toString());
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
