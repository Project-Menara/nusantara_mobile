import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';
import 'package:nusantara_mobile/features/favorite/domain/repositories/favorite_repository.dart';

class GetMyFavoriteUseCase {
  final FavoriteRepository repository;

  GetMyFavoriteUseCase(this.repository);

  Future<Either<Failures, List<FavoriteEntity>>> call() {
    return repository.getMyFavorite();
  }
}
