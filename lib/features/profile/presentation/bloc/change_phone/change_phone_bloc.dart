import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/request_change_phone_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_change_phone_usecase.dart';

part 'change_phone_event.dart';
part 'change_phone_state.dart';

class ChangePhoneBloc extends Bloc<ChangePhoneEvent, ChangePhoneState> {
  final RequestChangePhoneUseCase requestChangePhoneUseCase;
  final VerifyChangePhoneUseCase verifyChangePhoneUseCase;
  final AuthBloc authBloc; // Untuk refresh data user global

  ChangePhoneBloc({
    required this.requestChangePhoneUseCase,
    required this.verifyChangePhoneUseCase,
    required this.authBloc,
  }) : super(ChangePhoneInitial()) {
    on<RequestChangePhoneSubmitted>(_onRequestSubmitted);
    on<VerifyChangePhoneSubmitted>(_onVerifySubmitted);
  }

  Future<void> _onRequestSubmitted(
    RequestChangePhoneSubmitted event,
    Emitter<ChangePhoneState> emit,
  ) async {
    emit(RequestChangePhoneLoading());
    final params = RequestChangePhoneParams(newPhone: event.newPhone);
    final result = await requestChangePhoneUseCase(params);

    result.fold(
      (failure) => emit(RequestChangePhoneFailure(failure.message)),
      (_) => emit(RequestChangePhoneSuccess()),
    );
  }

  Future<void> _onVerifySubmitted(
    VerifyChangePhoneSubmitted event,
    Emitter<ChangePhoneState> emit,
  ) async {
    emit(VerifyChangePhoneLoading());
    final params = VerifyChangePhoneParams(phone: event.phone, code: event.code);
    final result = await verifyChangePhoneUseCase(params);

    result.fold(
      (failure) => emit(VerifyChangePhoneFailure(failure.message)),
      (_) {
        // Jika sukses, emit state sukses
        emit(VerifyChangePhoneSuccess());
        // Dan panggil AuthBloc untuk me-refresh data user di seluruh aplikasi
        authBloc.add(AuthCheckStatusRequested());
      },
    );
  }
}