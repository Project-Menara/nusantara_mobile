part of 'favorite_bloc.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final List<FavoriteEntity> items;
  final Set<String> favoriteProductIds; // For quick lookup

  const FavoriteLoaded({required this.items, required this.favoriteProductIds});

  @override
  List<Object?> get props => [items, favoriteProductIds];

  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }
}

class FavoriteEmpty extends FavoriteState {
  const FavoriteEmpty();
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoriteActionLoading extends FavoriteState {
  final List<FavoriteEntity> items;
  final Set<String> favoriteProductIds;
  final String actionType; // 'add' or 'remove'

  const FavoriteActionLoading({
    required this.items,
    required this.favoriteProductIds,
    required this.actionType,
  });

  @override
  List<Object?> get props => [items, favoriteProductIds, actionType];

  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }
}

class FavoriteActionSuccess extends FavoriteState {
  final String message;
  final List<FavoriteEntity> items;
  final Set<String> favoriteProductIds;

  const FavoriteActionSuccess({
    required this.message,
    required this.items,
    required this.favoriteProductIds,
  });

  @override
  List<Object?> get props => [message, items, favoriteProductIds];

  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }
}
