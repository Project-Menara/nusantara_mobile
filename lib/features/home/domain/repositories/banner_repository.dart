import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';

abstract class BannerRepository {
  Future<Either<Failures, List<BannerEntity>>> getBanners();
  Future<Either<Failures, BannerEntity>> getBannerById(String id);
}
