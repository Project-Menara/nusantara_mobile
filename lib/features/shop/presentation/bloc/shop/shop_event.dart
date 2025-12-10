import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class GetNearbyShopsEvent extends ShopEvent {
  final double lat;
  final double lng;

  const GetNearbyShopsEvent({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class GetShopDetailEvent extends ShopEvent {
  final String shopId;

  const GetShopDetailEvent({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}
