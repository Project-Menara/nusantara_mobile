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

  // Timer untuk monitoring token expiry
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
    print("🔧 AuthBloc: Constructor called - Creating new instance");
    print("🔧 AuthBloc: Instance hashCode: ${hashCode}");

    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthLoginWithPinSubmitted>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPinRequested>(_onForgotPinRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthTokenExpired>(_onTokenExpired);
    on<AuthForceTokenExpiredTest>(_onForceTokenExpiredTest);

    // <<< PERBAIKAN KRITIS: Daftarkan event handler di constructor >>>
    on<AuthUserUpdated>(_onAuthUserUpdated);

    // PERBAIKAN BARU: Auto-check status jika instance baru dibuat
    // Ini akan memastikan state di-restore otomatis tanpa perlu manual trigger
    _autoRestoreUserState();
  }

  // Method untuk auto-restore user state ketika AuthBloc dibuat
  void _autoRestoreUserState() async {
    try {
      print("🔄 AuthBloc: Auto-restoring user state...");
      final token = await localDatasource.getAuthToken();
      if (token != null && !JwtHelper.isTokenExpired(token)) {
        print("🔄 AuthBloc: Valid token found, auto-checking status");
        add(AuthCheckStatusRequested());
      } else {
        print("🔄 AuthBloc: No valid token found, staying unauthenticated");
      }
    } catch (e) {
      print("❌ AuthBloc: Error in auto-restore: $e");
    }
  }

  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthUpdateSuccess(event.newUser));
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    print("🔍 AuthBloc: _onCheckStatus started");
    print("🔍 AuthBloc: Current state before: ${state.runtimeType}");

    emit(AuthGetProfileLoading());
    print("🔍 AuthBloc: Emitted AuthGetProfileLoading");

    try {
      print("🔍 AuthBloc: Calling getLoggedInUserUseCase...");
      final result = await getLoggedInUserUseCase(NoParams());

      result.fold(
        (failure) {
          print(
            "❌ AuthBloc: getLoggedInUserUseCase failed with: ${failure.runtimeType}",
          );
          print("❌ AuthBloc: Failure message: ${failure.message}");
          print("❌ AuthBloc: Emitting AuthUnauthenticated");
          emit(AuthUnauthenticated());
        },
        (user) {
          print("✅ AuthBloc: getLoggedInUserUseCase success");
          print("✅ AuthBloc: User data: ${user.name} (${user.email})");
          print("✅ AuthBloc: Emitting AuthGetUserSuccess");
          emit(AuthGetUserSuccess(user));

          // Start token monitoring jika user sudah login
          print(
            "🔐 AuthBloc: Starting token expiry monitoring after status check",
          );
          _startTokenExpiryMonitoring();
        },
      );
    } catch (e) {
      print("💥 AuthBloc: Exception in _onCheckStatus: $e");
      print("💥 AuthBloc: Exception type: ${e.runtimeType}");
      print("💥 AuthBloc: Emitting AuthUnauthenticated due to exception");
      emit(AuthUnauthenticated());
    }

    print(
      "🔍 AuthBloc: _onCheckStatus completed with state: ${state.runtimeType}",
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

    // Start automatic token expiry monitoring setelah login berhasil
    print(
      "🔐 AuthBloc: Starting token expiry monitoring after successful login",
    );
    _startTokenExpiryMonitoring();
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    print("🔐 AuthBloc: Token expired detected, clearing authentication");

    // Stop token monitoring saat token expired
    _stopTokenExpiryMonitoring();

    // Clear local storage token
    try {
      await logoutUserUseCase(NoParams());
    } catch (e) {
      print("⚠️ AuthBloc: Error during logout: $e");
    }

    // Emit token expired state
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
    // Stop token monitoring saat logout
    _stopTokenExpiryMonitoring();

    emit(AuthLoginLoading());
    final result = await logoutUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthLogoutFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // Handler untuk force token expired testing
  Future<void> _onForceTokenExpiredTest(
    AuthForceTokenExpiredTest event,
    Emitter<AuthState> emit,
  ) async {
    print("🔐 AuthBloc: Force token expired test triggered");
    emit(const AuthTokenExpiredState(message: "Token expired - Test Mode"));
  }

  // Method untuk start monitoring token expiry
  void _startTokenExpiryMonitoring() {
    _stopTokenExpiryMonitoring(); // Stop existing timer jika ada

    // Check every 30 seconds
    _tokenExpiryTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      await _checkTokenExpiry();
    });

    print("🕐 AuthBloc: Started token expiry monitoring");
  }

  // Method untuk stop monitoring token expiry
  void _stopTokenExpiryMonitoring() {
    if (_tokenExpiryTimer != null) {
      _tokenExpiryTimer!.cancel();
      _tokenExpiryTimer = null;
      print("🛑 AuthBloc: Stopped token expiry monitoring");
    }
  }

  // Method untuk check token expiry
  Future<void> _checkTokenExpiry() async {
    try {
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        print("🔐 AuthBloc: No token found, stopping monitoring");
        _stopTokenExpiryMonitoring();
        return;
      }

      if (JwtHelper.isTokenExpired(token)) {
        final remainingTime = JwtHelper.getTokenRemainingTime(token);
        print(
          "⚠️ AuthBloc: Token expired! Remaining: ${JwtHelper.formatRemainingTime(remainingTime)}",
        );

        // Stop monitoring dan trigger token expired event
        _stopTokenExpiryMonitoring();
        add(const AuthTokenExpired(message: "Token sudah kedaluwarsa"));
      } else {
        final remainingTime = JwtHelper.getTokenRemainingTime(token);
        print(
          "✅ AuthBloc: Token valid. Remaining: ${JwtHelper.formatRemainingTime(remainingTime)}",
        );
      }
    } catch (e) {
      print("❌ AuthBloc: Error checking token expiry: $e");
    }
  }

  @override
  Future<void> close() {
    _stopTokenExpiryMonitoring();
    return super.close();
  }
}
