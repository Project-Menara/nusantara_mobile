part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartEntity> items;
  final int totalItems;
  final int totalPrice;

  const CartLoaded({
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [items, totalItems, totalPrice];
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartActionLoading extends CartState {
  final List<CartEntity> items;
  final String actionType; // 'add', 'delete', 'update'

  const CartActionLoading({required this.items, required this.actionType});

  @override
  List<Object?> get props => [items, actionType];
}

class CartActionSuccess extends CartState {
  final String message;
  final List<CartEntity> items;

  const CartActionSuccess({required this.message, required this.items});

  @override
  List<Object?> get props => [message, items];
}
