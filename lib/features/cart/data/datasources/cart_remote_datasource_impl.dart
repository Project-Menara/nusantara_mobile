import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:nusantara_mobile/features/cart/data/models/cart_model.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;
  final LocalDatasource localDatasource;
  final Function()? onTokenExpired;

  CartRemoteDataSourceImpl({
    required this.client,
    required this.localDatasource,
    this.onTokenExpired,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await localDatasource.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<CartModel>> getMyCart() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstant.baseUrl}/customer/my-cart');

      print('🛒 [GET CART] REQUEST:');
      print('   URL: $uri');
      print('   Headers: ${headers.keys.toList()}');

      final response = await client.get(uri, headers: headers);

      print('🛒 [GET CART] RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final cartList = CartModel.fromJsonList(response.body);
        print('✅ [GET CART] SUCCESS: ${cartList.length} items found');
        return cartList;
      } else if (response.statusCode == 404) {
        print('ℹ️ [GET CART] Cart is empty (404)');
        // Cart is empty - return empty list instead of throwing exception
        return [];
      } else if (response.statusCode == 401) {
        print('❌ [GET CART] UNAUTHORIZED');
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        print('❌ [GET CART] ERROR: ${data['message']}');
        throw ServerException(data['message'] ?? 'Failed to get cart');
      }
    } catch (e) {
      print('💥 [GET CART] EXCEPTION: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<String> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstant.baseUrl}/customer/add-cart-item');

      final body = jsonEncode({'product_id': productId, 'quantity': quantity});

      print('🛒 [ADD TO CART] REQUEST:');
      print('   URL: $uri');
      print('   Headers: ${headers.keys.toList()}');
      print('   Body: $body');

      final response = await client.post(uri, headers: headers, body: body);

      print('🛒 [ADD TO CART] RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ADD TO CART] SUCCESS: ${data['message']}');
        return data['message'] ?? 'Add Product To cart success';
      } else if (response.statusCode == 409) {
        // Product already exists - this might mean quantity was updated or blocked
        // We treat this as failure so the fallback DELETE+ADD strategy can be tried
        final data = jsonDecode(response.body);
        print('⚠️ [ADD TO CART] CONFLICT 409: ${data['message']}');
        print('⚠️ [ADD TO CART] Will try DELETE+ADD strategy...');
        throw ServerException(
          data['message'] ?? 'Product already exists in cart',
        );
      } else if (response.statusCode == 401) {
        print('❌ [ADD TO CART] UNAUTHORIZED');
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ADD TO CART] ERROR: ${data['message']}');
        throw ServerException(data['message'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      print('💥 [ADD TO CART] EXCEPTION: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<String> deleteCartItem(String productId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstant.baseUrl}/customer/delete-cart-item/$productId',
      );

      final response = await client.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Cart item deleted successfully';
      } else if (response.statusCode == 401) {
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        throw ServerException(data['message'] ?? 'Failed to delete cart item');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }
}
