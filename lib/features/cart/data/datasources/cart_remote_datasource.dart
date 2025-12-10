import 'package:nusantara_mobile/features/cart/data/models/cart_model.dart';

abstract class CartRemoteDataSource {
  /// Get user's cart items
  /// GET /customer/my-cart
  Future<List<CartModel>> getMyCart();

  /// Add product to cart
  /// POST /customer/add-cart-item
  /// Body: { "product_id": "...", "quantity": 1 }
  Future<String> addToCart({required String productId, required int quantity});

  /// Delete cart item
  /// DELETE /customer/delete-cart-item/:product_id
  Future<String> deleteCartItem(String productId);
}
