import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/event_repository.dart';

class GetAllEventUsecase implements Usecase<List<EventEntity>, NoParams> {
  final EventRepository eventRepository;

  GetAllEventUsecase(this.eventRepository);

  @override
  Future<Either<Failures, List<EventEntity>>> call(NoParams params) async {
    return eventRepository.getEvents();
  }
}
