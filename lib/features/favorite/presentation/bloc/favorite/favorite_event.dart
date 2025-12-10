part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class GetMyFavoriteEvent extends FavoriteEvent {
  const GetMyFavoriteEvent();
}

class AddToFavoriteEvent extends FavoriteEvent {
  final String productId;

  const AddToFavoriteEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class RemoveFromFavoriteEvent extends FavoriteEvent {
  final String productId;

  const RemoveFromFavoriteEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String productId;
  final bool isCurrentlyFavorite;

  const ToggleFavoriteEvent({
    required this.productId,
    required this.isCurrentlyFavorite,
  });

  @override
  List<Object?> get props => [productId, isCurrentlyFavorite];
}
