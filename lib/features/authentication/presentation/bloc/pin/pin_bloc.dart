import 'dart:async';
import 'package:bloc/bloc.dart';
// ...existing imports...
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
// removed unused imports
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_confirm_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/validate_forgot_pin_token_usecase.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  final CreatePinUseCase _createPinUseCase;
  final ConfirmPinUseCase _confirmPinUseCase;
  final SetNewPinForgotUseCase setNewPinForgotUseCase;
  final ConfirmNewPinForgotUseCase confirmNewPinForgotUseCase;
  final ValidateForgotPinTokenUseCase validateForgotPinTokenUseCase;

  PinBloc({
    required CreatePinUseCase createPinUseCase,
    required ConfirmPinUseCase confirmPinUseCase,
    required this.setNewPinForgotUseCase,
    required this.confirmNewPinForgotUseCase,
    required this.validateForgotPinTokenUseCase,
  }) : _createPinUseCase = createPinUseCase,
       _confirmPinUseCase = confirmPinUseCase,
       super(PinInitial()) {
    on<ValidateForgotPinToken>(_onValidateForgotPinToken);

    on<CreatePinSubmitted>(_onCreatePinSubmitted);
    on<ConfirmPinSubmitted>(_onConfirmPinSubmitted);
    on<SetNewPinForgotSubmitted>(_onSetNewPinForgotSubmitted);
    on<ConfirmNewPinForgotSubmitted>(_onConfirmNewPinForgotSubmitted);
  }

  Future<void> _onValidateForgotPinToken(
    ValidateForgotPinToken event,
    Emitter<PinState> emit,
  ) async {
    emit(ResetTokenValidationLoading());

    // --- PERBAIKAN DI SINI ---
    // 1. Buat instance dari Params object terlebih dahulu
    final params = ValidateForgotPinTokenParams(token: event.token);

    // 2. Panggil use case dengan params object tersebut
    final result = await validateForgotPinTokenUseCase(params);

    result.fold(
      (failure) => emit(ResetTokenInvalid(failure.message)),
      (_) => emit(ResetTokenValid()),
    );
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
    result.fold((failure) {
      if (failure is TokenExpiredFailure) {
        emit(SetNewPinForgotTokenExpired(failure.message));
      } else {
        emit(SetNewPinForgotError(failure.message));
      }
    }, (_) => emit(SetNewPinForgotSuccess()));
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
    result.fold((failure) {
      if (failure is TokenExpiredFailure) {
        emit(ConfirmNewPinForgotTokenExpired(failure.message));
      } else {
        emit(ConfirmNewPinForgotError(failure.message));
      }
    }, (user) => emit(ConfirmNewPinForgotSuccess(user as UserModel)));
  }
}
