import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventAllLoading extends EventState {}

class EventAllLoaded extends EventState {
  final List<EventEntity> events;

  const EventAllLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventAllError extends EventState {
  final String message;

  const EventAllError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventDetailLoading extends EventState {}

class EventDetailLoaded extends EventState {
  final EventEntity event;

  const EventDetailLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventDetailError extends EventState {
  final String message;

  const EventDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
