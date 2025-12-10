import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/favorite/domain/repositories/favorite_repository.dart';

class AddToFavoriteUseCase {
  final FavoriteRepository repository;

  AddToFavoriteUseCase(this.repository);

  Future<Either<Failures, String>> call(String productId) {
    return repository.addToFavorite(productId);
  }
}
