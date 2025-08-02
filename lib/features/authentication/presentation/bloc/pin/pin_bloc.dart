import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/set_confirm_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/set_new_pin_forgot_usecase.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  // === PERUBAHAN: Simpan kedua use case ===
  final CreatePinUseCase _createPinUseCase;
  final ConfirmPinUseCase _confirmPinUseCase;
  final SetNewPinForgotUseCase setNewPinForgotUseCase;
  final ConfirmNewPinForgotUseCase confirmNewPinForgotUseCase;
  PinBloc({
    required CreatePinUseCase createPinUseCase,
    required ConfirmPinUseCase confirmPinUseCase,
    required this.setNewPinForgotUseCase,
    required this.confirmNewPinForgotUseCase,
  }) : _createPinUseCase = createPinUseCase,
       _confirmPinUseCase = confirmPinUseCase,
       super(PinInitial()) {
    on<CreatePinSubmitted>(_onCreatePinSubmitted);
    on<ConfirmPinSubmitted>(_onConfirmPinSubmitted);
    on<SetNewPinForgotSubmitted>(_onSetNewPinForgotSubmitted);
    on<ConfirmNewPinForgotSubmitted>(_onConfirmNewPinForgotSubmitted);
  }

  Future<void> _onCreatePinSubmitted(
    CreatePinSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading());
    final result = await _createPinUseCase(
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    );

    result.fold(
      (failure) => emit(PinCreationError(failure.message)),
      (_) => emit(PinCreationSuccess()),
    );
  }

  Future<void> _onConfirmPinSubmitted(
    ConfirmPinSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading());

    final result = await _confirmPinUseCase(
      phone: event.phoneNumber,
      confirmPin: event.pin,
    );

    result.fold(
      (failure) => emit(PinConfirmationError(failure.message)),
      (user) => emit(PinConfirmationSuccess(user as UserModel)),
    );
  }

  Future<void> _onSetNewPinForgotSubmitted(
    SetNewPinForgotSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading());
    final params = SetNewPinForgotParams(
      token: event.token,
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    );
    final result = await setNewPinForgotUseCase(params);
    result.fold(
      (failure) => emit(SetNewPinForgotError(failure.message)),
      (_) => emit(SetNewPinForgotSuccess()),
    );
  }

  Future<void> _onConfirmNewPinForgotSubmitted(
    ConfirmNewPinForgotSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading());
    final params = ConfirmNewPinForgotParams(
      token: event.token,
      phoneNumber: event.phoneNumber,
      confirmPin: event.pin,
    );
    final result = await confirmNewPinForgotUseCase(params);
    result.fold(
      (failure) => emit(ConfirmNewPinForgotError(failure.message)),
      (user) => emit(ConfirmNewPinForgotSuccess(user as UserModel)),
    );
  }
}
