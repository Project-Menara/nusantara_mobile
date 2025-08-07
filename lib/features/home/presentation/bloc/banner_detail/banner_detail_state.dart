part of 'banner_detail_bloc.dart';

abstract class BannerDetailState extends Equatable {
  const BannerDetailState();
  @override
  List<Object> get props => [];
}

class BannerDetailInitial extends BannerDetailState {}

class BannerDetailLoading extends BannerDetailState {}

class BannerDetailLoaded extends BannerDetailState {
  final BannerEntity banner;
  const BannerDetailLoaded({required this.banner});
  @override
  List<Object> get props => [banner];
}

class BannerDetailError extends BannerDetailState {
  final String message;
  const BannerDetailError({required this.message});
  @override
  List<Object> get props => [message];
}