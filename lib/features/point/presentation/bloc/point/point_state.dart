import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';

abstract class PointState extends Equatable {
  const PointState();

  @override
  List<Object?> get props => [];
}

class PointInitial extends PointState {
  const PointInitial();
}

class PointLoading extends PointState {
  const PointLoading();
}

class PointLoaded extends PointState {
  final PointEntity point;

  const PointLoaded(this.point);

  @override
  List<Object?> get props => [point];
}

class PointHistoryLoaded extends PointState {
  final List<PointHistoryEntity> history;

  const PointHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class PointDataLoaded extends PointState {
  final PointEntity point;
  final List<PointHistoryEntity> history;

  const PointDataLoaded({required this.point, required this.history});

  @override
  List<Object?> get props => [point, history];
}

class PointError extends PointState {
  final String message;

  const PointError(this.message);

  @override
  List<Object?> get props => [message];
}
