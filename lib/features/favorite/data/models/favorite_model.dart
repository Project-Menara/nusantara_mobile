import 'dart:convert';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';

class FavoriteModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int price;
  final String unit;
  final String? description;
  final String typeProduct;
  final List<String> productImages;
  final bool selected;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.unit,
    this.description,
    required this.typeProduct,
    required this.productImages,
    required this.selected,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    final product = json['Product'] as Map<String, dynamic>?;

    return FavoriteModel(
      id: json['id']?.toString() ?? '',
      productId: product?['id']?.toString() ?? '',
      productName: product?['name']?.toString() ?? '',
      productImage: product?['image']?.toString(),
      price: (product?['price'] is int)
          ? product!['price'] as int
          : int.tryParse(product?['price']?.toString() ?? '0') ?? 0,
      unit: product?['unit']?.toString() ?? 'PIECES',
      description: product?['description']?.toString(),
      typeProduct: product?['type_product']?.toString() ?? '',
      productImages:
          (product?['product_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      selected: json['selected'] ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  FavoriteEntity toEntity() {
    return FavoriteEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      unit: unit,
      description: description,
      typeProduct: typeProduct,
      productImages: productImages,
      selected: selected,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<FavoriteModel> fromJsonList(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final List<FavoriteModel> list = [];

    print('💝 [FavoriteModel] Parsing response...');
    print('💝 [FavoriteModel] Response keys: ${map.keys.toList()}');

    // Check if data exists and has favorite_item
    if (map['data'] != null && map['data'] is Map<String, dynamic>) {
      final data = map['data'] as Map<String, dynamic>;
      print('💝 [FavoriteModel] Data keys: ${data.keys.toList()}');

      if (data['favorite_item'] != null && data['favorite_item'] is List) {
        final favoriteItems = data['favorite_item'] as List;
        print(
          '💝 [FavoriteModel] Found ${favoriteItems.length} favorite items',
        );

        for (final item in favoriteItems) {
          if (item is Map<String, dynamic>) {
            try {
              final favoriteModel = FavoriteModel.fromJson(item);
              list.add(favoriteModel);
              print('✅ [FavoriteModel] Parsed: ${favoriteModel.productName}');
            } catch (e) {
              print('❌ [FavoriteModel] Error parsing item: $e');
            }
          }
        }
      }
    }

    print('✅ [FavoriteModel] Total parsed: ${list.length} items');
    return list;
  }
}
