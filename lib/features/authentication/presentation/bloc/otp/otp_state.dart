import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object> get props => [];
}

class OtpInitial extends OtpState {}

class OtpVerificationLoading extends OtpState {}

class OtpVerificationSuccess extends OtpState {}

class OtpVerificationFailure extends OtpState {
  final String message;

  const OtpVerificationFailure(this.message);

  @override
  List<Object> get props => [message];
}