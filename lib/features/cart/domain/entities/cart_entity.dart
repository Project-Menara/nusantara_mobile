import 'package:equatable/equatable.dart';

class CartEntity extends Equatable {
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

  const CartEntity({
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

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productImage,
    description,
    price,
    quantity,
    unit,
    totalPrice,
    shopId,
    shopName,
    createdAt,
    updatedAt,
  ];
}
