import 'package:nusantara_mobile/features/shop/data/models/shop_model.dart';

abstract class ShopRemoteDataSource {
  Future<List<ShopModel>> getNearbyShops({
    required double lat,
    required double lng,

    /// If true, call the public (no-auth) endpoint
    bool public = false,
  });

  /// Get shop detail by ID
  Future<ShopModel> getShopDetail({required String shopId});
}
