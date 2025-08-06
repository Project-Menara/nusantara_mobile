import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failures, List<CategoryEntity>>> getAllCategories();
  Future<Either<Failures, CategoryEntity>> getCategoryById(String id);
}
