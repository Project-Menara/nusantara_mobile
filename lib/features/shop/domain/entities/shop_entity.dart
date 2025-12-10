import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String name;
  final String cover;
  final String description;
  final String fullAddress;
  final double lat;
  final double lang;
  final int status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updateAt;
  final DateTime? deletedAt;
  final List<String> shopImages;
  final List<ProductEntity> shopProduct;
  final List<CashierEntity> shopCashier;
  final String distance;

  const ShopEntity({
    required this.id,
    required this.name,
    required this.cover,
    required this.description,
    required this.fullAddress,
    required this.lat,
    required this.lang,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updateAt,
    this.deletedAt,
    required this.shopImages,
    required this.shopProduct,
    required this.shopCashier,
    required this.distance,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    cover,
    description,
    fullAddress,
    lat,
    lang,
    status,
    createdBy,
    createdAt,
    updateAt,
    deletedAt,
    shopImages,
    shopProduct,
    shopCashier,
    distance,
  ];
}

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String image;
  final String code;
  final int price;
  final String unit;
  final String description;
  final int status;
  final String typeProduct;
  final List<String> productImages;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.code,
    required this.price,
    required this.unit,
    required this.description,
    required this.status,
    required this.typeProduct,
    required this.productImages,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    code,
    price,
    unit,
    description,
    status,
    typeProduct,
    productImages,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

class CashierEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String photo;
  final int status;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deletedAt;

  const CashierEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.photo,
    required this.status,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
    photo,
    status,
    role,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
