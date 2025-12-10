import 'dart:convert';
import 'package:nusantara_mobile/features/cart/domain/entities/cart_entity.dart';

class CartModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final String? description;
  final int price;
  final int quantity;
  final String unit;
  final int totalPrice;
  final String shopId;
  final String shopName;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.totalPrice,
    required this.shopId,
    required this.shopName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] is int)
          ? json['price'] as int
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: (json['quantity'] is int)
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unit: json['unit']?.toString() ?? '',
      totalPrice: (json['total_price'] is int)
          ? json['total_price'] as int
          : int.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'total_price': totalPrice,
      'shop_id': shopId,
      'shop_name': shopName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImage: productImage,
      description: description,
      price: price,
      quantity: quantity,
      unit: unit,
      totalPrice: totalPrice,
      shopId: shopId,
      shopName: shopName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<CartModel> fromJsonList(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final List<CartModel> list = [];

    print('🔍 [CartModel] Parsing response...');
    print('🔍 [CartModel] Response keys: ${map.keys.toList()}');

    // Check if data exists and has cart_items
    if (map['data'] != null && map['data'] is Map<String, dynamic>) {
      final data = map['data'] as Map<String, dynamic>;
      print('🔍 [CartModel] Data keys: ${data.keys.toList()}');

      if (data['cart_items'] != null && data['cart_items'] is List) {
        final cartItems = data['cart_items'] as List;
        print('🔍 [CartModel] Found ${cartItems.length} cart items');

        for (final item in cartItems) {
          if (item is Map<String, dynamic>) {
            try {
              // Parse cart item with nested Product
              final product = item['Product'] as Map<String, dynamic>?;
              if (product != null) {
                final cartModel = CartModel(
                  id: item['id']?.toString() ?? '',
                  productId: product['id']?.toString() ?? '',
                  productName: product['name']?.toString() ?? '',
                  productImage: product['image']?.toString(),
                  description: product['description']?.toString(),
                  price: (product['price'] is int)
                      ? product['price'] as int
                      : int.tryParse(product['price']?.toString() ?? '0') ?? 0,
                  quantity:
                      1, // Default quantity, bisa disesuaikan jika ada field quantity
                  unit: product['unit']?.toString() ?? 'PIECES',
                  totalPrice: (product['price'] is int)
                      ? product['price'] as int
                      : int.tryParse(product['price']?.toString() ?? '0') ?? 0,
                  shopId: '', // TODO: Add if available in response
                  shopName: '', // TODO: Add if available in response
                  createdAt:
                      DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(item['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                );
                list.add(cartModel);
                print('✅ [CartModel] Parsed: ${cartModel.productName}');
              }
            } catch (e) {
              print('❌ [CartModel] Error parsing item: $e');
            }
          }
        }
      }
    }
    // Fallback: check if data is directly a list (old format)
    else if (map['data'] is List) {
      print('🔍 [CartModel] Using legacy list format');
      for (final item in map['data']) {
        if (item is Map<String, dynamic>) {
          list.add(CartModel.fromJson(item));
        }
      }
    }

    print('✅ [CartModel] Total parsed: ${list.length} items');
    return list;
  }
}
