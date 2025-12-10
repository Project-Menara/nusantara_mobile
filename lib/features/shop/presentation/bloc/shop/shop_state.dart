import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ShopEntity> shops;

  const ShopLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShopDetailLoading extends ShopState {}

class ShopDetailLoaded extends ShopState {
  final ShopEntity shop;

  const ShopDetailLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class ShopDetailError extends ShopState {
  final String message;

  const ShopDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
