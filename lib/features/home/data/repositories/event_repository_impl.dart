import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/home/data/datasources/event_service.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource eventRemoteDatasource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.eventRemoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<EventEntity>>> getEvents() async {
    if (await networkInfo.isConnected) {
      try {
        final events = await eventRemoteDatasource.getAllEvents();
        return Right(events);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failures, EventEntity>> getEventById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final event = await eventRemoteDatasource.getEventById(id);
        return Right(event);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No Internet Connection'));
    }
  }
}
