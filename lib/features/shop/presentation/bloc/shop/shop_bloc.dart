import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/shop/domain/usecases/get_nearby_shops_usecase.dart';
import 'package:nusantara_mobile/features/shop/domain/usecases/get_shop_detail_usecase.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_event.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetNearbyShopsUseCase getNearbyShopsUseCase;
  final GetShopDetailUseCase getShopDetailUseCase;

  ShopBloc({
    required this.getNearbyShopsUseCase,
    required this.getShopDetailUseCase,
  }) : super(ShopInitial()) {
    on<GetNearbyShopsEvent>(_onGetNearbyShops);
    on<GetShopDetailEvent>(_onGetShopDetail);
  }

  Future<void> _onGetNearbyShops(
    GetNearbyShopsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(ShopLoading());

    final result = await getNearbyShopsUseCase(
      NearbyShopsParams(lat: event.lat, lng: event.lng),
    );

    result.fold(
      (failure) => emit(ShopError(failure.message)),
      (shops) => emit(ShopLoaded(shops)),
    );
  }

  Future<void> _onGetShopDetail(
    GetShopDetailEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(ShopDetailLoading());

    final result = await getShopDetailUseCase(
      GetShopDetailParams(shopId: event.shopId),
    );

    result.fold(
      (failure) => emit(ShopDetailError(failure.message)),
      (shop) => emit(ShopDetailLoaded(shop)),
    );
  }
}
