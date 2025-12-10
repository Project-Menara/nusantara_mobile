import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/cart/domain/entities/cart_entity.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/delete_cart_item_usecase.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/get_my_cart_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetMyCartUseCase getMyCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;

  CartBloc({
    required this.getMyCartUseCase,
    required this.addToCartUseCase,
    required this.deleteCartItemUseCase,
  }) : super(const CartInitial()) {
    on<GetMyCartEvent>(_onGetMyCart);
    on<AddToCartEvent>(_onAddToCart);
    on<DeleteCartItemEvent>(_onDeleteCartItem);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
  }

  Future<void> _onGetMyCart(
    GetMyCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    final result = await getMyCartUseCase();

    result.fold((failure) => emit(CartError(failure.message)), (items) {
      if (items.isEmpty) {
        emit(const CartEmpty());
      } else {
        final totalItems = items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
        final totalPrice = items.fold<int>(
          0,
          (sum, item) => sum + item.totalPrice,
        );
        emit(
          CartLoaded(
            items: items,
            totalItems: totalItems,
            totalPrice: totalPrice,
          ),
        );
      }
    });
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    print(
      '📦 [CartBloc] AddToCart Event: productId=${event.productId}, quantity=${event.quantity}',
    );

    // Keep current items if available
    List<CartEntity> currentItems = [];
    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).items;
      print('📦 [CartBloc] Current cart has ${currentItems.length} items');
    }

    emit(CartActionLoading(items: currentItems, actionType: 'add'));
    print('📦 [CartBloc] State: CartActionLoading');

    final result = await addToCartUseCase(
      productId: event.productId,
      quantity: event.quantity,
    );

    await result.fold(
      (failure) async {
        print('❌ [CartBloc] AddToCart Failed: ${failure.message}');
        emit(CartError(failure.message));
      },
      (message) async {
        print('✅ [CartBloc] AddToCart Success: $message');
        print('🔄 [CartBloc] Refreshing cart...');

        // After successful add, refresh cart
        final cartResult = await getMyCartUseCase();
        cartResult.fold(
          (failure) {
            print('❌ [CartBloc] Refresh Failed: ${failure.message}');
            emit(CartError(failure.message));
          },
          (items) {
            if (items.isEmpty) {
              print('ℹ️ [CartBloc] Cart is empty after refresh');
              emit(const CartEmpty());
            } else {
              final totalItems = items.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
              final totalPrice = items.fold<int>(
                0,
                (sum, item) => sum + item.totalPrice,
              );
              print(
                '✅ [CartBloc] Cart refreshed: $totalItems items, totalPrice: $totalPrice',
              );
              emit(CartActionSuccess(message: message, items: items));
              emit(
                CartLoaded(
                  items: items,
                  totalItems: totalItems,
                  totalPrice: totalPrice,
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _onDeleteCartItem(
    DeleteCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    // Keep current items if available
    List<CartEntity> currentItems = [];
    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).items;
    }

    emit(CartActionLoading(items: currentItems, actionType: 'delete'));

    final result = await deleteCartItemUseCase(event.productId);

    await result.fold((failure) async => emit(CartError(failure.message)), (
      message,
    ) async {
      // After successful delete, refresh cart
      final cartResult = await getMyCartUseCase();
      cartResult.fold((failure) => emit(CartError(failure.message)), (items) {
        if (items.isEmpty) {
          emit(const CartEmpty());
        } else {
          final totalItems = items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          );
          final totalPrice = items.fold<int>(
            0,
            (sum, item) => sum + item.totalPrice,
          );
          emit(
            CartLoaded(
              items: items,
              totalItems: totalItems,
              totalPrice: totalPrice,
            ),
          );
        }
      });
    });
  }

  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    print(
      '🔄 [CartBloc] UpdateQuantity Event: productId=${event.productId}, newQuantity=${event.quantity}',
    );

    // Keep current items if available
    List<CartEntity> currentItems = [];
    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).items;
      print('🔄 [CartBloc] Current cart has ${currentItems.length} items');
    }

    emit(CartActionLoading(items: currentItems, actionType: 'update'));
    print('🔄 [CartBloc] State: CartActionLoading');

    // Strategy 1: Coba update menggunakan POST add-cart-item dengan quantity baru
    // Jika API sudah support update via POST, ini akan berhasil
    // Jika return 409, kita perlu delete dulu lalu add
    final addResult = await addToCartUseCase(
      productId: event.productId,
      quantity: event.quantity,
    );

    await addResult.fold(
      (failure) async {
        print('❌ [CartBloc] Update via POST failed: ${failure.message}');
        print('🔄 [CartBloc] Trying DELETE then ADD strategy...');

        // Strategy 2: Delete dulu, lalu add dengan quantity baru
        final deleteResult = await deleteCartItemUseCase(event.productId);

        await deleteResult.fold(
          (deleteFailure) async {
            print('❌ [CartBloc] Delete failed: ${deleteFailure.message}');
            emit(CartError(deleteFailure.message));
          },
          (_) async {
            print(
              '✅ [CartBloc] Delete success, now adding with new quantity...',
            );

            // Add with new quantity
            final reAddResult = await addToCartUseCase(
              productId: event.productId,
              quantity: event.quantity,
            );

            await reAddResult.fold(
              (addFailure) async {
                print('❌ [CartBloc] Re-add failed: ${addFailure.message}');
                emit(CartError(addFailure.message));

                // Refresh cart anyway to get current state
                final cartResult = await getMyCartUseCase();
                cartResult.fold(
                  (failure) =>
                      print('❌ [CartBloc] Refresh failed: ${failure.message}'),
                  (items) {
                    if (items.isEmpty) {
                      emit(const CartEmpty());
                    } else {
                      final totalItems = items.fold<int>(
                        0,
                        (sum, item) => sum + item.quantity,
                      );
                      final totalPrice = items.fold<int>(
                        0,
                        (sum, item) => sum + item.totalPrice,
                      );
                      emit(
                        CartLoaded(
                          items: items,
                          totalItems: totalItems,
                          totalPrice: totalPrice,
                        ),
                      );
                    }
                  },
                );
              },
              (message) async {
                print('✅ [CartBloc] Re-add success: $message');
                _refreshCart(emit);
              },
            );
          },
        );
      },
      (message) async {
        print('✅ [CartBloc] Update via POST success: $message');
        _refreshCart(emit);
      },
    );
  }

  Future<void> _refreshCart(Emitter<CartState> emit) async {
    print('🔄 [CartBloc] Refreshing cart...');
    final cartResult = await getMyCartUseCase();
    cartResult.fold(
      (failure) {
        print('❌ [CartBloc] Refresh failed: ${failure.message}');
        emit(CartError(failure.message));
      },
      (items) {
        if (items.isEmpty) {
          print('ℹ️ [CartBloc] Cart is empty after refresh');
          emit(const CartEmpty());
        } else {
          final totalItems = items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          );
          final totalPrice = items.fold<int>(
            0,
            (sum, item) => sum + item.totalPrice,
          );
          print(
            '✅ [CartBloc] Cart refreshed: $totalItems items, totalPrice: $totalPrice',
          );
          emit(
            CartLoaded(
              items: items,
              totalItems: totalItems,
              totalPrice: totalPrice,
            ),
          );
        }
      },
    );
  }
}
