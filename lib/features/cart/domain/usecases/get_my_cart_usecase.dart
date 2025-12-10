import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/cart/domain/entities/cart_entity.dart';
import 'package:nusantara_mobile/features/cart/domain/repositories/cart_repository.dart';

class GetMyCartUseCase {
  final CartRepository repository;

  GetMyCartUseCase(this.repository);

  Future<Either<Failures, List<CartEntity>>> call() async {
    return await repository.getMyCart();
  }
}
