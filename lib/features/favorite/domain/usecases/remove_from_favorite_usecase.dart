import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/favorite/domain/repositories/favorite_repository.dart';

class RemoveFromFavoriteUseCase {
  final FavoriteRepository repository;

  RemoveFromFavoriteUseCase(this.repository);

  Future<Either<Failures, String>> call(String productId) {
    return repository.removeFromFavorite(productId);
  }
}
