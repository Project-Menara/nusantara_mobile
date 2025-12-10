import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class GetAllEventsEvent extends EventEvent {}

class GetEventByIdEvent extends EventEvent {
  final String id;

  const GetEventByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}
