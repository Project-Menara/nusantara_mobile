import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';

abstract class ShopRepository {
  Future<Either<Failures, List<ShopEntity>>> getNearbyShops({
    required double lat,
    required double lng,
  });

  Future<Either<Failures, ShopEntity>> getShopDetail({required String shopId});
}
