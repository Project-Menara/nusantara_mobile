import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/shop/domain/repositories/shop_repository.dart';

class GetNearbyShopsUseCase
    implements Usecase<List<ShopEntity>, NearbyShopsParams> {
  final ShopRepository repository;

  GetNearbyShopsUseCase(this.repository);

  @override
  Future<Either<Failures, List<ShopEntity>>> call(
    NearbyShopsParams params,
  ) async {
    return await repository.getNearbyShops(lat: params.lat, lng: params.lng);
  }
}

class NearbyShopsParams extends Equatable {
  final double lat;
  final double lng;

  const NearbyShopsParams({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];
}
