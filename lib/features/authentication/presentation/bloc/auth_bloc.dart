import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nusantara_mobile/core/usecase/usecase.dart'; // Impor untuk NoParams
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone_usecase.dart';
// import 'package:nusantara_mobile/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_pin_and_login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneUseCase checkPhoneUseCase;
  final VerifyPinAndLoginUseCase verifyPinAndLoginUseCase;
  final RegisterUseCase registerUseCase;
  // final LogoutUseCase logoutUseCase; // LogoutUseCase diaktifkan kembali

  AuthBloc({
    required this.checkPhoneUseCase,
    required this.verifyPinAndLoginUseCase,
    required this.registerUseCase,
    // required this.logoutUseCase, // Diaktifkan kembali
  }) : super(AuthInitial()) {
    on<AuthCheckPhonePressed>(_onCheckPhone);
    on<AuthVerifyPinPressed>(_onVerifyPin);
    on<AuthRegisterPressed>(_onRegister);
    // on<AuthLogoutPressed>(_onLogout);
  }

  Future<void> _onCheckPhone(
    AuthCheckPhonePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await checkPhoneUseCase(event.phoneNumber);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (checkResult) => emit(AuthCheckPhoneSuccess(checkResult)),
      );
    } catch (e) {
      // Menambahkan try-catch untuk menangani error tak terduga
      emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyPin(
    AuthVerifyPinPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final params = VerifyPinParams(phoneNumber: event.phoneNumber, pin: event.pin);
      final result = await verifyPinAndLoginUseCase(params);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthLoginSuccess(user)),
      );
    } catch (e) {
      // Menambahkan try-catch untuk menangani error tak terduga
      emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final params = RegisterParams(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        gender: event.gender,
        pin: event.pin,
      );
      final result = await registerUseCase(params);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthRegisterSuccess()),
      );
    } catch (e) {
      // Menambahkan try-catch untuk menangani error tak terduga
      emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Future<void> _onLogout(
  //   AuthLogoutPressed event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     // Memanggil use case dengan parameter yang benar (asumsi NoParams)
  //     final result = await logoutUseCase(NoParams());
  //     result.fold(
  //       (failure) => emit(AuthFailure(failure.message)),
  //       (_) => emit(AuthLogoutSuccess()),
  //     );
  //   } catch (e) {
  //     // Menambahkan try-catch untuk menangani error tak terduga
  //     emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
  //   }
  // }
}