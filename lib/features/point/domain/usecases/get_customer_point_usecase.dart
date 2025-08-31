import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/domain/repositories/point_repository.dart';

class GetCustomerPointUseCase implements Usecase<PointEntity, NoParams> {
  final PointRepository repository;

  GetCustomerPointUseCase(this.repository);

  @override
  Future<Either<Failures, PointEntity>> call(NoParams params) async {
    return await repository.getCustomerPoint();
  }
}
