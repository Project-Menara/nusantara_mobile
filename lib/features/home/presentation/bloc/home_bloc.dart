import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // final HomeRepository homeRepository; // Nanti diinjeksi dari domain layer

  HomeBloc(/*{required this.homeRepository}*/) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Di dunia nyata, Anda akan memanggil:
      // final promos = await homeRepository.getPromos();
      // final events = await homeRepository.getEvents();
      // dll.

      // Untuk saat ini, kita gunakan data palsu (mock)
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network delay
      final mockPromos = [
        PromoEntity('assets/images/banner_burger.jpg'),
        PromoEntity('assets/images/banner_burger.jpg'),
        PromoEntity('assets/images/banner_burger.jpg'),
      ];
      
      emit(HomeLoaded(promos: mockPromos));

    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}