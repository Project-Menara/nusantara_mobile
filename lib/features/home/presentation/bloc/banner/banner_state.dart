import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';

abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

class BannerInitial extends BannerState {}

class BannerAllLoading extends BannerState {}

class BannerAllLoaded extends BannerState {
  final List<BannerEntity> banners;

  const BannerAllLoaded({required this.banners});

  @override
  List<Object?> get props => [banners];
}

class BannerAllError extends BannerState {
  final String message;
  const BannerAllError(this.message);

  @override
  List<Object?> get props => [message];
}

class BannerByIdLoading extends BannerState {}

class BannerByIdLoaded extends BannerState {
  final BannerEntity banner;

  const BannerByIdLoaded({required this.banner});

  @override
  List<Object?> get props => [banner];
}

class BannerByIdError extends BannerState {
  final String message;
  const BannerByIdError(this.message);

  @override
  List<Object?> get props => [message];
}
