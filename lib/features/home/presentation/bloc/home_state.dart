part of 'home_bloc.dart';

// Ganti class ini dengan entity dari domain layer Anda nanti
// Contoh sederhana:
class PromoEntity {
  final String imageUrl;
  PromoEntity(this.imageUrl);
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // State ini akan membawa data yang berhasil dimuat
  final List<PromoEntity> promos;
  // final List<EventEntity> events;
  // final List<StoreEntity> stores;

  const HomeLoaded({required this.promos});

  @override
  List<Object> get props => [promos];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}