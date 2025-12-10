import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/add_to_favorite_usecase.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/get_my_favorite_usecase.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/remove_from_favorite_usecase.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetMyFavoriteUseCase getMyFavoriteUseCase;
  final AddToFavoriteUseCase addToFavoriteUseCase;
  final RemoveFromFavoriteUseCase removeFromFavoriteUseCase;

  FavoriteBloc({
    required this.getMyFavoriteUseCase,
    required this.addToFavoriteUseCase,
    required this.removeFromFavoriteUseCase,
  }) : super(const FavoriteInitial()) {
    on<GetMyFavoriteEvent>(_onGetMyFavorite);
    on<AddToFavoriteEvent>(_onAddToFavorite);
    on<RemoveFromFavoriteEvent>(_onRemoveFromFavorite);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetMyFavorite(
    GetMyFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    print('💝 [FavoriteBloc] GetMyFavorite Event');
    emit(const FavoriteLoading());

    final result = await getMyFavoriteUseCase();

    result.fold(
      (failure) {
        print('❌ [FavoriteBloc] GetMyFavorite Failed: ${failure.message}');
        emit(FavoriteError(failure.message));
      },
      (items) {
        if (items.isEmpty) {
          print('ℹ️ [FavoriteBloc] Favorite is empty');
          emit(const FavoriteEmpty());
        } else {
          final productIds = items.map((item) => item.productId).toSet();
          print('✅ [FavoriteBloc] Favorite loaded: ${items.length} items');
          emit(FavoriteLoaded(items: items, favoriteProductIds: productIds));
        }
      },
    );
  }

  Future<void> _onAddToFavorite(
    AddToFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    print(
      '💝 [FavoriteBloc] AddToFavorite Event: productId=${event.productId}',
    );

    // Keep current items if available
    List<FavoriteEntity> currentItems = [];
    Set<String> currentProductIds = {};
    if (state is FavoriteLoaded) {
      currentItems = (state as FavoriteLoaded).items;
      currentProductIds = Set.from(
        (state as FavoriteLoaded).favoriteProductIds,
      );
    }

    // 🚀 OPTIMISTIC UPDATE: Langsung update UI sebelum API call
    final optimisticProductIds = Set<String>.from(currentProductIds)
      ..add(event.productId);
    emit(
      FavoriteLoaded(
        items: currentItems,
        favoriteProductIds: optimisticProductIds,
      ),
    );
    print('⚡ [FavoriteBloc] Optimistic Update: Added ${event.productId} to UI');

    final result = await addToFavoriteUseCase(event.productId);

    await result.fold(
      (failure) async {
        print('❌ [FavoriteBloc] AddToFavorite Failed: ${failure.message}');
        // Revert optimistic update
        emit(
          FavoriteLoaded(
            items: currentItems,
            favoriteProductIds: currentProductIds,
          ),
        );
        emit(FavoriteError(failure.message));
      },
      (message) async {
        print('✅ [FavoriteBloc] AddToFavorite API Success: $message');

        // Langsung refresh dari server untuk dapat data item lengkap
        print('🔄 [FavoriteBloc] Fetching updated favorite list...');
        final favoriteResult = await getMyFavoriteUseCase();
        favoriteResult.fold(
          (failure) {
            print('⚠️ [FavoriteBloc] Refresh failed: ${failure.message}');
            // Keep optimistic state if refresh fails
            emit(
              FavoriteActionSuccess(
                message: message,
                items: currentItems,
                favoriteProductIds: optimisticProductIds,
              ),
            );
          },
          (items) {
            final productIds = items.map((item) => item.productId).toSet();
            print('✅ [FavoriteBloc] Refreshed: ${items.length} items');
            // Emit success dengan data terbaru dari server
            emit(
              FavoriteActionSuccess(
                message: message,
                items: items,
                favoriteProductIds: productIds,
              ),
            );
            // Then emit loaded state
            emit(FavoriteLoaded(items: items, favoriteProductIds: productIds));
          },
        );
      },
    );
  }

  Future<void> _onRemoveFromFavorite(
    RemoveFromFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    print(
      '💝 [FavoriteBloc] RemoveFromFavorite Event: productId=${event.productId}',
    );

    // Keep current items if available
    List<FavoriteEntity> currentItems = [];
    Set<String> currentProductIds = {};
    if (state is FavoriteLoaded) {
      currentItems = (state as FavoriteLoaded).items;
      currentProductIds = Set.from(
        (state as FavoriteLoaded).favoriteProductIds,
      );
    }

    // 🚀 OPTIMISTIC UPDATE: Langsung update UI sebelum API call
    final optimisticProductIds = Set<String>.from(currentProductIds)
      ..remove(event.productId);

    // Filter out item dari list juga untuk optimistic update
    final optimisticItems = currentItems
        .where((item) => item.productId != event.productId)
        .toList();

    if (optimisticItems.isEmpty) {
      emit(const FavoriteEmpty());
    } else {
      emit(
        FavoriteLoaded(
          items: optimisticItems,
          favoriteProductIds: optimisticProductIds,
        ),
      );
    }
    print(
      '⚡ [FavoriteBloc] Optimistic Update: Removed ${event.productId} from UI',
    );

    final result = await removeFromFavoriteUseCase(event.productId);

    await result.fold(
      (failure) async {
        print('❌ [FavoriteBloc] RemoveFromFavorite Failed: ${failure.message}');
        // Revert optimistic update
        emit(
          FavoriteLoaded(
            items: currentItems,
            favoriteProductIds: currentProductIds,
          ),
        );
        emit(FavoriteError(failure.message));
      },
      (message) async {
        print('✅ [FavoriteBloc] RemoveFromFavorite API Success: $message');

        // Langsung refresh dari server untuk sinkronisasi
        print('🔄 [FavoriteBloc] Fetching updated favorite list...');
        final favoriteResult = await getMyFavoriteUseCase();
        favoriteResult.fold(
          (failure) {
            print('⚠️ [FavoriteBloc] Refresh failed: ${failure.message}');
            // Keep optimistic state if refresh fails
            emit(
              FavoriteActionSuccess(
                message: message,
                items: optimisticItems,
                favoriteProductIds: optimisticProductIds,
              ),
            );
            if (optimisticItems.isEmpty) {
              emit(const FavoriteEmpty());
            }
          },
          (items) {
            print('✅ [FavoriteBloc] Refreshed: ${items.length} items');
            if (items.isEmpty) {
              emit(
                FavoriteActionSuccess(
                  message: message,
                  items: [],
                  favoriteProductIds: {},
                ),
              );
              emit(const FavoriteEmpty());
            } else {
              final productIds = items.map((item) => item.productId).toSet();
              // Emit success dengan data terbaru dari server
              emit(
                FavoriteActionSuccess(
                  message: message,
                  items: items,
                  favoriteProductIds: productIds,
                ),
              );
              emit(
                FavoriteLoaded(items: items, favoriteProductIds: productIds),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    print(
      '💝 [FavoriteBloc] ToggleFavorite: productId=${event.productId}, current=${event.isCurrentlyFavorite}',
    );

    if (event.isCurrentlyFavorite) {
      // Remove from favorite
      add(RemoveFromFavoriteEvent(event.productId));
    } else {
      // Add to favorite
      add(AddToFavoriteEvent(event.productId));
    }
  }
}
