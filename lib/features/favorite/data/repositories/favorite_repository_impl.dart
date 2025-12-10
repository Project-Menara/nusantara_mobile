import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';
import 'package:nusantara_mobile/features/favorite/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<FavoriteEntity>>> getMyFavorite() async {
    try {
      final result = await remoteDataSource.getMyFavorite();
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failures, String>> addToFavorite(String productId) async {
    try {
      final result = await remoteDataSource.addToFavorite(productId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failures, String>> removeFromFavorite(String productId) async {
    try {
      final result = await remoteDataSource.removeFromFavorite(productId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failures, bool>> isFavorite(String productId) async {
    try {
      final favorites = await remoteDataSource.getMyFavorite();
      final isFav = favorites.any((item) => item.productId == productId);
      return Right(isFav);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
