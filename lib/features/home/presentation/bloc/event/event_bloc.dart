import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/event/get_all_event_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/event/get_event_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetAllEventUsecase getAllEventUsecase;
  final GetEventByIdUsecase getEventByIdUsecase;

  EventBloc({
    required this.getAllEventUsecase,
    required this.getEventByIdUsecase,
  }) : super(EventInitial()) {
    on<GetAllEventsEvent>(_onGetAllEvents);
    on<GetEventByIdEvent>(_onGetEventById);
  }

  Future<void> _onGetAllEvents(
    GetAllEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventAllLoading());
    final result = await getAllEventUsecase(NoParams());
    result.fold(
      (failure) => emit(EventAllError(MapFailureToMessage.map(failure))),
      (events) => emit(EventAllLoaded(events: events)),
    );
  }

  Future<void> _onGetEventById(
    GetEventByIdEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventDetailLoading());
    final result = await getEventByIdUsecase(EventDetailParams(id: event.id));
    result.fold(
      (failure) => emit(EventDetailError(MapFailureToMessage.map(failure))),
      (eventEntity) => emit(EventDetailLoaded(event: eventEntity)),
    );
  }
}
