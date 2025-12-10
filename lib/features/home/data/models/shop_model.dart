import 'dart:convert';

class ShopProductModel {
  final String id;
  final String name;
  final String? image;
  final int price;
  final String unit;
  final String typeProduct; // add category/type

  ShopProductModel({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    required this.unit,
    required this.typeProduct,
  });

  factory ShopProductModel.fromJson(Map<String, dynamic> json) =>
      ShopProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        price: (json['price'] is int)
            ? json['price'] as int
            : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
        unit: json['unit']?.toString() ?? '',
        typeProduct: json['type_product']?.toString() ?? '',
      );
}

class ShopModel {
  final String id;
  final String name;
  final String? cover;
  final String? description;
  final String? fullAddress;
  final double? lat;
  final double? lang;
  final String? distance;
  final List<ShopProductModel> products;

  ShopModel({
    required this.id,
    required this.name,
    this.cover,
    this.description,
    this.fullAddress,
    this.lat,
    this.lang,
    this.distance,
    required this.products,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    final prodList = <ShopProductModel>[];
    if (json['shop_product'] is List) {
      for (final p in json['shop_product']) {
        if (p is Map<String, dynamic>)
          prodList.add(ShopProductModel.fromJson(p));
      }
    }

    return ShopModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cover: json['cover']?.toString(),
      description: json['description']?.toString(),
      fullAddress: json['full_address']?.toString(),
      lat: (json['lat'] != null)
          ? double.tryParse(json['lat'].toString())
          : null,
      lang: (json['lang'] != null)
          ? double.tryParse(json['lang'].toString())
          : null,
      distance: json['distance']?.toString(),
      products: prodList,
    );
  }

  static List<ShopModel> listFromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final List<ShopModel> list = [];
    if (map['data'] is List) {
      for (final item in map['data']) {
        if (item is Map<String, dynamic>) list.add(ShopModel.fromJson(item));
      }
    }
    return list;
  }
}
