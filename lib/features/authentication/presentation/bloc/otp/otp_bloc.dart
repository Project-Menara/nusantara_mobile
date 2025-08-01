import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/resend_code_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code_use_case.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResendCodeUseCase resendCodeUseCase; // <-- TAMBAHKAN

  OtpBloc({
    required this.verifyCodeUseCase,
    required this.resendCodeUseCase, // <-- TAMBAHKAN
  }) : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested); // <-- TAMBAHKAN
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpVerificationLoading());

    // --- PERBAIKAN DI SINI ---
    // 1. Buat objek parameter terlebih dahulu
    final params = VerifyCodeParams(
      phoneNumber: event.phoneNumber,
      code: event.code,
    );

    // 2. Kirim objek parameter tersebut ke dalam use case
    final result = await verifyCodeUseCase(params);

    result.fold(
      (failure) => emit(OtpVerificationFailure(failure.message)),
      (_) => emit(OtpVerificationSuccess()),
    );
  }

  // --- TAMBAHKAN HANDLER BARU INI ---
  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpResendLoading());
    final result = await resendCodeUseCase(event.phoneNumber);
    result.fold((failure) {
      // --- TAMBAHKAN LOGIKA INI ---
      if (failure is ServerFailure &&
          failure.message.toLowerCase().contains('failed to send otp')) {
        emit(
          const OtpResendFailure(
            'Terjadi kesalahan saat mengirim ulang. Coba lagi dalam beberapa saat.',
          ),
        );
      } else {
        emit(OtpResendFailure(failure.message));
      }
      // --------------------------
    }, (_) => emit(OtpResendSuccess()));
  }
}
