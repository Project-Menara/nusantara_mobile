import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/banner_repository.dart';

class GetBannerByIdUsecase implements Usecase<BannerEntity, DetailParams> {
  final BannerRepository bannerRepository;

  GetBannerByIdUsecase(this.bannerRepository);

  @override
  Future<Either<Failures, BannerEntity>> call(DetailParams params) async {
    return await bannerRepository.getBannerById(params.id);
  }
}

class DetailParams extends Equatable {
  final String id;

  const DetailParams({required this.id});
  @override
  List<Object?> get props => [id];
}
