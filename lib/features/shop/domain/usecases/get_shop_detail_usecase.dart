import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/shop/domain/repositories/shop_repository.dart';

class GetShopDetailUseCase {
  final ShopRepository repository;

  GetShopDetailUseCase(this.repository);

  Future<Either<Failures, ShopEntity>> call(GetShopDetailParams params) async {
    return await repository.getShopDetail(shopId: params.shopId);
  }
}

class GetShopDetailParams extends Equatable {
  final String shopId;

  const GetShopDetailParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}
