part of 'otp_bloc.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

class OtpSubmitted extends OtpEvent {
  final String phoneNumber;
  final String code;

  const OtpSubmitted({required this.phoneNumber, required this.code});

  @override
  List<Object> get props => [phoneNumber, code];
}

class OtpResendRequested extends OtpEvent {
  final String phoneNumber;

  const OtpResendRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
