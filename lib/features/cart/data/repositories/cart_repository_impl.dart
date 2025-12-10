import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:nusantara_mobile/features/cart/domain/entities/cart_entity.dart';
import 'package:nusantara_mobile/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<CartEntity>>> getMyCart() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMyCart();
        final entities = result.map((model) => model.toEntity()).toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failures, String>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final message = await remoteDataSource.addToCart(
          productId: productId,
          quantity: quantity,
        );
        return Right(message);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failures, String>> deleteCartItem(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final message = await remoteDataSource.deleteCartItem(productId);
        return Right(message);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
