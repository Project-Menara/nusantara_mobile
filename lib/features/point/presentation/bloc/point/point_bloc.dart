import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_usecase.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_history_usecase.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_event.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_state.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  final GetCustomerPointUseCase getCustomerPointUseCase;
  final GetCustomerPointHistoryUseCase getCustomerPointHistoryUseCase;

  PointBloc({
    required this.getCustomerPointUseCase,
    required this.getCustomerPointHistoryUseCase,
  }) : super(const PointInitial()) {
    on<GetCustomerPointEvent>(_onGetCustomerPoint);
    on<GetCustomerPointHistoryEvent>(_onGetCustomerPointHistory);
    on<RefreshPointDataEvent>(_onRefreshPointData);
  }

  Future<void> _onGetCustomerPoint(
    GetCustomerPointEvent event,
    Emitter<PointState> emit,
  ) async {
    emit(const PointLoading());

    // debug: 🎯 PointBloc: Getting customer point...

    final result = await getCustomerPointUseCase(NoParams());

    result.fold(
      (failure) {
        // debug: ❌ PointBloc: Failed to get customer point: ${failure.message}
        emit(PointError(failure.message));
      },
      (point) {
        // debug: ✅ PointBloc: Customer point loaded successfully: ${point.totalPoints} points
        // debug: 🔍 PointBloc: Point expiry debug:
        // debug:   - expiredDates: ${point.expiredDates}
        // debug:   - totalExpired: ${point.totalExpired}
        // debug:   - Full point entity: $point
        emit(PointLoaded(point));
      },
    );
  }

  Future<void> _onGetCustomerPointHistory(
    GetCustomerPointHistoryEvent event,
    Emitter<PointState> emit,
  ) async {
    emit(const PointLoading());

    // debug: 🎯 PointBloc: Getting customer point history...

    final result = await getCustomerPointHistoryUseCase(NoParams());

    result.fold(
      (failure) {
        // debug: ❌ PointBloc: Failed to get customer point history: ${failure.message}
        emit(PointError(failure.message));
      },
      (history) {
        // debug: ✅ PointBloc: Customer point history loaded successfully: ${history.length} entries
        emit(PointHistoryLoaded(history));
      },
    );
  }

  Future<void> _onRefreshPointData(
    RefreshPointDataEvent event,
    Emitter<PointState> emit,
  ) async {
    emit(const PointLoading());

    // debug: 🎯 PointBloc: Refreshing all point data...

    try {
      // Get both point and history data in parallel
      final results = await Future.wait([
        getCustomerPointUseCase(NoParams()),
        getCustomerPointHistoryUseCase(NoParams()),
      ]);

      final pointResult = results[0];
      final historyResult = results[1];

      // Check if both requests succeeded
      if (pointResult.isRight() && historyResult.isRight()) {
        late final PointEntity point;
        late final List<PointHistoryEntity> history;

        pointResult.fold((l) => null, (r) => point = r as PointEntity);
        historyResult.fold(
          (l) => null,
          (r) => history = r as List<PointHistoryEntity>,
        );

        // debug: ✅ PointBloc: All point data refreshed successfully
        emit(PointDataLoaded(point: point, history: history));
      } else {
        // Handle failure - prioritize point failure over history failure
        if (pointResult.isLeft()) {
          final failure = pointResult.fold((l) => l, (r) => null);
          // debug: ❌ PointBloc: Failed to refresh point data: ${failure?.message}
          emit(PointError(failure?.message ?? 'Failed to load point data'));
        } else {
          final failure = historyResult.fold((l) => l, (r) => null);
          // debug: ❌ PointBloc: Failed to refresh history data: ${failure?.message}
          emit(PointError(failure?.message ?? 'Failed to load point history'));
        }
      }
    } catch (e) {
      // debug: 💥 PointBloc: Unexpected error during refresh: $e
      emit(PointError('Terjadi kesalahan saat memuat data point: $e'));
    }
  }
}
