import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logout_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_pin_and_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetLoggedInUserUseCase getLoggedInUserUseCase;
  final CheckPhoneUseCase checkPhoneUseCase;
  final VerifyPinAndLoginUseCase verifyPinAndLoginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUserUseCase logoutUserUseCase; // <-- PASTIKAN BARIS INI ADA

  AuthBloc({
    required this.getLoggedInUserUseCase,
    required this.checkPhoneUseCase,
    required this.verifyPinAndLoginUseCase,
    required this.registerUseCase,
    required this.logoutUserUseCase, // --- TAMBAHKAN INI ---
  }) : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthLoginWithPinSubmitted>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
    on<AuthLogoutRequested>(_onLogout); // --- TAMBAHKAN INI ---
  }
  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getLoggedInUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthLoginSuccess(user)),
    );
  }

  Future<void> _onCheckPhone(
    AuthCheckPhonePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
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
    emit(AuthLoading());
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
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(registerEntity: event.registerEntity),
    );
    result.fold(
      (failure) => emit(AuthRegisterFailure(failure.message)),
      (user) => emit(AuthRegisterSuccess(user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message) as AuthState),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
