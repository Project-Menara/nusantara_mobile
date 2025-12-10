import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/cart/domain/repositories/cart_repository.dart';

class DeleteCartItemUseCase {
  final CartRepository repository;

  DeleteCartItemUseCase(this.repository);

  Future<Either<Failures, String>> call(String productId) async {
    return await repository.deleteCartItem(productId);
  }
}
