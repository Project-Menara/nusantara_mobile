import 'package:flutter_bloc/flutter_bloc.dart';
// Pastikan path impor ini benar
import 'package:nusantara_mobile/core/error/failures.dart'; 
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_pin_and_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneUseCase checkPhoneUseCase;
  final VerifyPinAndLoginUseCase verifyPinAndLoginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.checkPhoneUseCase,
    required this.verifyPinAndLoginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthLoginWithPinSubmitted>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
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
    result.fold(
      (failure) {
        // ✅ PERBAIKAN UTAMA: Periksa tipe Failure secara spesifik
        if (failure is RateLimitFailure) {
          // Jika failure adalah RateLimitFailure, emit state khusus
          emit(AuthLoginRateLimited(
            message: failure.message,
            retryAfterSeconds: failure.retryAfterSeconds,
          ));
        } else {
          // Untuk semua jenis failure lainnya, emit state kegagalan umum
          emit(AuthLoginFailure(failure.message));
        }
      },
      (user) => emit(AuthLoginSuccess(user)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final params = RegisterParams(
      name: event.name,
      username: event.username,
      email: event.email,
      phone: event.phone,
      gender: event.gender,
    );
    final result = await registerUseCase(params);
    result.fold(
      (failure) => emit(AuthRegisterFailure(failure.message)),
      (_) => emit(AuthRegisterSuccess()),
    );
  }
}