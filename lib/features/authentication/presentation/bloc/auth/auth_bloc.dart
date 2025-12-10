// lib/features/authentication/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/core/utils/jwt_helper.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
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
  final LocalDatasource localDatasource;

  Timer? _tokenExpiryTimer;

  AuthBloc({
    required this.getLoggedInUserUseCase,
    required this.checkPhoneUseCase,
    required this.verifyPinAndLoginUseCase,
    required this.registerUseCase,
    required this.logoutUserUseCase,
    required this.forgotPinUseCase,
    required this.localDatasource,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthLoginWithPinSubmitted>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPinRequested>(_onForgotPinRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthTokenExpired>(_onTokenExpired);
    on<AuthForceTokenExpiredTest>(_onForceTokenExpiredTest);
    on<AuthUserUpdated>(_onAuthUserUpdated);

    _autoRestoreUserState();
  }

  void _autoRestoreUserState() async {
    try {
      final token = await localDatasource.getAuthToken();
      if (token != null && !JwtHelper.isTokenExpired(token)) {
        add(AuthCheckStatusRequested());
      }
    } catch (e) {}
  }

  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthUpdateSuccess(event.newUser));
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGetProfileLoading());
    try {
      final result = await getLoggedInUserUseCase(NoParams());
      result.fold(
        (failure) {
          emit(AuthUnauthenticated());
        },
        (user) {
          emit(AuthGetUserSuccess(user));
          _startTokenExpiryMonitoring();
        },
      );
    } catch (e) {
      emit(AuthUnauthenticated());
    }
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
    _startTokenExpiryMonitoring();
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    _stopTokenExpiryMonitoring();
    try {
      await logoutUserUseCase(NoParams());
    } catch (e) {}
    emit(
      AuthTokenExpiredState(
        message:
            event.message ?? 'Token sudah kedaluwarsa. Silakan login kembali.',
      ),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _stopTokenExpiryMonitoring();
    emit(AuthLoginLoading());
    final result = await logoutUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthLogoutFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onForceTokenExpiredTest(
    AuthForceTokenExpiredTest event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthTokenExpiredState(message: "Token expired - Test Mode"));
  }

  void _startTokenExpiryMonitoring() {
    _stopTokenExpiryMonitoring();
    _tokenExpiryTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      await _checkTokenExpiry();
    });
  }

  void _stopTokenExpiryMonitoring() {
    if (_tokenExpiryTimer != null) {
      _tokenExpiryTimer!.cancel();
      _tokenExpiryTimer = null;
    }
  }

  Future<void> _checkTokenExpiry() async {
    try {
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        _stopTokenExpiryMonitoring();
        return;
      }

      if (JwtHelper.isTokenExpired(token)) {
        _stopTokenExpiryMonitoring();
        add(const AuthTokenExpired(message: "Token sudah kedaluwarsa"));
      }
    } catch (e) {}
  }

  @override
  Future<void> close() {
    _stopTokenExpiryMonitoring();
    return super.close();
  }
}
