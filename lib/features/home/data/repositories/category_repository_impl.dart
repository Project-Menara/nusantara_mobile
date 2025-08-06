import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/home/data/dataSource/category_remote_dataSource.dart';
import 'package:nusantara_mobile/features/home/data/models/category_model.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/category_repository.dart';

 class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource categoryRemoteDatasource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.categoryRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<CategoryEntity>>> getAllCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await categoryRemoteDatasource.getAllCategories();
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, CategoryModel>> getCategoryById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await categoryRemoteDatasource.getCategoryById(id);
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
