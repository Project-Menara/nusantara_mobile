import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_all_banner_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_banner_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final GetAllBannerUsecase getAllBannerUsecase;
  final GetBannerByIdUsecase getBannerByIdUsecase;

  BannerBloc({
    required this.getAllBannerUsecase,
    required this.getBannerByIdUsecase,
  }) : super(BannerInitial()) {
    on<GetAllBannerEvent>(_onGetAllBanner);
    on<GetByIdBannerEvent>(_onGetByIdBanner);
  }

  Future<void> _onGetAllBanner(
    GetAllBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerAllLoading());
    final bannerOrFailure = await getAllBannerUsecase(NoParams());
    bannerOrFailure.fold(
      (failures) => emit(BannerAllError(MapFailureToMessage.map(failures))),
      (banners) => emit(BannerAllLoaded(banners: banners)),
    );
  }

  Future<void> _onGetByIdBanner(
    GetByIdBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerByIdLoading());
    final bannerOrfailure = await getBannerByIdUsecase(
      DetailParams(id: event.id),
    );
    bannerOrfailure.fold(
      (failures) => emit(BannerByIdError(MapFailureToMessage.map(failures))),
      (banner) => emit(BannerByIdLoaded(banner: banner)),
    );
  }
}
