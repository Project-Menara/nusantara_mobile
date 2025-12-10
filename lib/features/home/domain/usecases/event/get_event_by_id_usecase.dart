import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/event_repository.dart';

class GetEventByIdUsecase implements Usecase<EventEntity, EventDetailParams> {
  final EventRepository eventRepository;

  GetEventByIdUsecase(this.eventRepository);

  @override
  Future<Either<Failures, EventEntity>> call(EventDetailParams params) async {
    return eventRepository.getEventById(params.id);
  }
}

class EventDetailParams extends Equatable {
  final String id;

  const EventDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}
