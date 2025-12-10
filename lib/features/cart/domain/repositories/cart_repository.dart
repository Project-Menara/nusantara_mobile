import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/cart/domain/entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<Failures, List<CartEntity>>> getMyCart();
  Future<Either<Failures, String>> addToCart({
    required String productId,
    required int quantity,
  });
  Future<Either<Failures, String>> deleteCartItem(String productId);
}
