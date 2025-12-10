import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    required super.id,
    required super.name,
    required super.cover,
    required super.description,
    required super.fullAddress,
    required super.lat,
    required super.lang,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updateAt,
    super.deletedAt,
    required super.shopImages,
    required super.shopProduct,
    required super.shopCashier,
    required super.distance,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    print('\n🏪🏪🏪 SHOP MODEL FROM JSON 🏪🏪🏪');
    print('Shop Name: ${json['name']}');
    print('shop_product type: ${json['shop_product'].runtimeType}');
    if (json['shop_product'] is List) {
      print('shop_product length: ${(json['shop_product'] as List).length}');
    }
    print('🏪🏪🏪 END SHOP MODEL 🏪🏪🏪\n');

    return ShopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cover: json['cover'] ?? '',
      description: json['description'] ?? '',
      fullAddress: json['full_address'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lang: (json['lang'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 0,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(json['update_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      shopImages:
          (json['shop_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      shopProduct:
          (json['shop_product'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
      shopCashier:
          (json['shop_cashier'] as List<dynamic>?)
              ?.map((e) => CashierModel.fromJson(e))
              .toList() ??
          [],
      distance: json['distance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'description': description,
      'full_address': fullAddress,
      'lat': lat,
      'lang': lang,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'shop_images': shopImages,
      'shop_product': shopProduct
          .map((e) => (e as ProductModel).toJson())
          .toList(),
      'shop_cashier': shopCashier
          .map((e) => (e as CashierModel).toJson())
          .toList(),
      'distance': distance,
    };
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.image,
    required super.code,
    required super.price,
    required super.unit,
    required super.description,
    required super.status,
    required super.typeProduct,
    required super.productImages,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 🎯 MENGGUNAKAN PARSING YANG SAMA DENGAN FavoriteModel
    print('\n');
    print('━' * 60);
    print('🚨🚨🚨 PRODUCT MODEL FROM JSON 🚨🚨🚨');
    print('Product Name: ${json['name']}');
    print('JSON Keys: ${json.keys.toList()}');

    // ✨ CHECK NULL FIRST
    if (json['product_images'] == null) {
      print('⚠️⚠️⚠️ product_images is NULL!');
    } else {
      print('product_images raw: ${json['product_images']}');
      print('product_images type: ${json['product_images'].runtimeType}');
      print(
        'product_images length (if List): ${(json['product_images'] as List?)?.length}',
      );
    }

    // EXACT SAMA SEPERTI FavoriteModel - simple casting tanpa decode
    final productImages =
        (json['product_images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    print('✅ Parsed productImages: $productImages');
    print('✅ Length: ${productImages.length}');
    print('🚨🚨🚨 END PRODUCT MODEL 🚨🚨🚨');
    print('━' * 60);
    print('\n');

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      code: json['code'] ?? '',
      price: json['price'] ?? 0,
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      typeProduct: json['type_product'] ?? '',
      productImages: productImages,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'code': code,
      'price': price,
      'unit': unit,
      'description': description,
      'status': status,
      'type_product': typeProduct,
      'product_images': productImages,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

class CashierModel extends CashierEntity {
  const CashierModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.photo,
    required super.status,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'] ?? '',
      status: json['status'] ?? 0,
      role: json['role'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: DateTime.tryParse(json['deleted_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'photo': photo,
      'status': status,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt.toIso8601String(),
    };
  }
}
