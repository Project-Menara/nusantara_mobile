part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class GetMyCartEvent extends CartEvent {
  const GetMyCartEvent();
}

class AddToCartEvent extends CartEvent {
  final String productId;
  final int quantity;

  const AddToCartEvent({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class DeleteCartItemEvent extends CartEvent {
  final String productId;

  const DeleteCartItemEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartItemQuantityEvent extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantityEvent({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
