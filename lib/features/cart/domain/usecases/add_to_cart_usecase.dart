import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/cart/domain/repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failures, String>> call({
    required String productId,
    required int quantity,
  }) async {
    return await repository.addToCart(productId: productId, quantity: quantity);
  }
}
