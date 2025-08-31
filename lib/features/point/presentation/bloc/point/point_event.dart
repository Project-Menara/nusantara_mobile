import 'package:equatable/equatable.dart';

abstract class PointEvent extends Equatable {
  const PointEvent();

  @override
  List<Object?> get props => [];
}

class GetCustomerPointEvent extends PointEvent {
  const GetCustomerPointEvent();
}

class GetCustomerPointHistoryEvent extends PointEvent {
  const GetCustomerPointHistoryEvent();
}

class RefreshPointDataEvent extends PointEvent {
  const RefreshPointDataEvent();
}
