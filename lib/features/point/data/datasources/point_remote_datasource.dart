import 'package:nusantara_mobile/features/point/data/models/point_history_model.dart';
import 'package:nusantara_mobile/features/point/data/models/point_model.dart';

abstract class PointRemoteDatasource {
  Future<PointModel> getCustomerPoint();
  Future<List<PointHistoryModel>> getCustomerPointHistory();
}
