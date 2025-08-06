import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/category_repository.dart';

class GetAllCategoryUsecase implements Usecase<List<CategoryEntity>, NoParams> {
  final CategoryRepository repository;

  GetAllCategoryUsecase(this.repository);

  @override
  Future<Either<Failures, List<CategoryEntity>>> call(NoParams params) {
    return repository.getAllCategories();
  }
}
