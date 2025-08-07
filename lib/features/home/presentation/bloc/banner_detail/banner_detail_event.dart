part of 'banner_detail_bloc.dart';

abstract class BannerDetailEvent extends Equatable {
  const BannerDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchBannerDetail extends BannerDetailEvent {
  final String id;
  const FetchBannerDetail({required this.id});
  @override
  List<Object> get props => [id];
}