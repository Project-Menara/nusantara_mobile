import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';
import 'package:nusantara_mobile/features/point/domain/repositories/point_repository.dart';

class GetCustomerPointHistoryUseCase
    implements Usecase<List<PointHistoryEntity>, NoParams> {
  final PointRepository repository;

  GetCustomerPointHistoryUseCase(this.repository);

  @override
  Future<Either<Failures, List<PointHistoryEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getCustomerPointHistory();
  }
}
