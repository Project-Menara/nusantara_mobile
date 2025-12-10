import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
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

  const FavoriteEntity({
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

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productImage,
    price,
    unit,
    description,
    typeProduct,
    productImages,
    selected,
    createdAt,
    updatedAt,
  ];
}
