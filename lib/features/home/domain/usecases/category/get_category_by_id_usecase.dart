import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/category_repository.dart';

class GetCategoryByIdUsecase implements Usecase<CategoryEntity, Params> {
  final CategoryRepository repository;

  GetCategoryByIdUsecase(this.repository);

  @override
  Future<Either<Failures, CategoryEntity>> call(Params params) {
    return repository.getCategoryById(params.id);
  }
}

class Params {
  final String id;

  Params({required this.id});
}
