import 'package:nusantara_mobile/features/favorite/data/models/favorite_model.dart';

abstract class FavoriteRemoteDataSource {
  /// Get user's favorite items
  /// GET /customer/my-favorite
  Future<List<FavoriteModel>> getMyFavorite();

  /// Add product to favorite
  /// POST /customer/add-favorite-item
  /// Body: { "product_id": "..." }
  Future<String> addToFavorite(String productId);

  /// Delete favorite item
  /// DELETE /customer/delete-favorite-item/:product_id
  Future<String> removeFromFavorite(String productId);
}
