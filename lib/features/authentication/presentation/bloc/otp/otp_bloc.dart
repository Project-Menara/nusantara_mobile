import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code_use_case.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyCodeUseCase verifyCodeUseCase;

  OtpBloc({required this.verifyCodeUseCase}) : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpVerificationLoading());
    final result = await verifyCodeUseCase(
      phoneNumber: event.phoneNumber,
      code: event.code,
    );

    result.fold(
      (failure) => emit(OtpVerificationFailure(failure.message)),
      (_) => emit(OtpVerificationSuccess()),
    );
  }
}
