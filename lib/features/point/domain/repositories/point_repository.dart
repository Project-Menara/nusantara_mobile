import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';

abstract class PointRepository {
  Future<Either<Failures, PointEntity>> getCustomerPoint();
  Future<Either<Failures, List<PointHistoryEntity>>> getCustomerPointHistory();
}
