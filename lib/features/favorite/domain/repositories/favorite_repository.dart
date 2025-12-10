import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';

abstract class FavoriteRepository {
  /// Get user's favorite items
  Future<Either<Failures, List<FavoriteEntity>>> getMyFavorite();

  /// Add product to favorite
  Future<Either<Failures, String>> addToFavorite(String productId);

  /// Remove product from favorite
  Future<Either<Failures, String>> removeFromFavorite(String productId);

  /// Check if product is in favorite
  Future<Either<Failures, bool>> isFavorite(String productId);
}
