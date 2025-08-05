import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/banner_repository.dart';

class GetAllBannerUsecase implements Usecase<List<BannerEntity>, NoParams> {
  final BannerRepository bannerRepository;

  GetAllBannerUsecase(this.bannerRepository);

  @override
  Future<Either<Failures, List<BannerEntity>>> call(NoParams params) async {
    return await bannerRepository.getBanners();
  }
}
