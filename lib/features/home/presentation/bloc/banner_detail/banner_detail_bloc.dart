import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_banner_by_id_usecase.dart';

part 'banner_detail_event.dart';
part 'banner_detail_state.dart';

class BannerDetailBloc extends Bloc<BannerDetailEvent, BannerDetailState> {
  final GetBannerByIdUsecase getBannerByIdUseCase;

  BannerDetailBloc({required this.getBannerByIdUseCase}) : super(BannerDetailInitial()) {
    on<FetchBannerDetail>(_onFetchBannerDetail);
  }

  Future<void> _onFetchBannerDetail(
    FetchBannerDetail event,
    Emitter<BannerDetailState> emit,
  ) async {
    emit(BannerDetailLoading());
    final result = await getBannerByIdUseCase(DetailParams(id: event.id));
    result.fold(
      (failure) => emit(BannerDetailError(message: MapFailureToMessage.map(failure))),
      (banner) => emit(BannerDetailLoaded(banner: banner)),
    );
  }
}