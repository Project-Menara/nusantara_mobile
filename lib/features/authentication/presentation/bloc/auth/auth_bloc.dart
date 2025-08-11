// lib/features/authentication/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/forgot_pin_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logged_in/get_logged_in_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logout/logout_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/login/verify_pin_and_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetLoggedInUserUseCase getLoggedInUserUseCase;
  final CheckPhoneUseCase checkPhoneUseCase;
  final VerifyPinAndLoginUseCase verifyPinAndLoginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUserUseCase logoutUserUseCase;
  final ForgotPinUseCase forgotPinUseCase;

  AuthBloc({
    required this.getLoggedInUserUseCase,
    required this.checkPhoneUseCase,
    required this.verifyPinAndLoginUseCase,
    required this.registerUseCase,
    required this.logoutUserUseCase,
    required this.forgotPinUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthLoginWithPinSubmitted>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPinRequested>(_onForgotPinRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);

    // <<< PERBAIKAN KRITIS: Daftarkan event handler di constructor >>>
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthUpdateSuccess(event.newUser));
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGetProfileLoading());
    final result = await getLoggedInUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthGetUserSuccess(user)),
    );
  }

  Future<void> _onCheckPhone(
    AuthCheckPhonePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCheckPhoneLoading());
    final result = await checkPhoneUseCase(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthCheckPhoneFailure(failure.message)),
      (checkResult) => emit(AuthCheckPhoneSuccess(checkResult)),
    );
  }

  Future<void> _onVerifyPin(
    AuthLoginWithPinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());
    final params = VerifyPinParams(
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    );
    final result = await verifyPinAndLoginUseCase(params);
    result.fold((failure) {
      if (failure is RateLimitFailure) {
        emit(
          AuthLoginRateLimited(
            message: failure.message,
            retryAfterSeconds: failure.retryAfterSeconds,
          ),
        );
      } else {
        emit(AuthLoginFailure(failure.message));
      }
    }, (user) => emit(AuthLoginSuccess(user)));
  }

  Future<void> _onRegister(
    AuthRegisterPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthRegisterLoading());
    final result = await registerUseCase(
      RegisterParams(registerEntity: event.registerEntity),
    );
    result.fold(
      (failure) => emit(AuthRegisterFailure(failure.message)),
      (user) => emit(AuthRegisterSuccess(user)),
    );
  }

  Future<void> _onForgotPinRequested(
    AuthForgotPinRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthForgotPinLoading());
    final result = await forgotPinUseCase(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthForgotPinFailure(failure.message)),
      (token) => emit(AuthForgotPinSuccess(token)),
    );
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthLoginSuccess(event.user));
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());
    final result = await logoutUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthLogoutFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
