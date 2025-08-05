import 'package:equatable/equatable.dart';

abstract class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

class GetAllBannerEvent extends BannerEvent {}

class GetByIdBannerEvent extends BannerEvent {
  final String id;

  const GetByIdBannerEvent(this.id);

  @override
  List<Object?> get props => [id];
}
