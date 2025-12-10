import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failures, List<EventEntity>>> getEvents();
  Future<Either<Failures, EventEntity>> getEventById(String id);
}
