part of 'change_phone_bloc.dart';

abstract class ChangePhoneState extends Equatable {
  const ChangePhoneState();
  @override
  List<Object> get props => [];
}

class ChangePhoneInitial extends ChangePhoneState {}

// States untuk proses request OTP
class RequestChangePhoneLoading extends ChangePhoneState {}
class RequestChangePhoneSuccess extends ChangePhoneState {}
class RequestChangePhoneFailure extends ChangePhoneState {
  final String message;
  const RequestChangePhoneFailure(this.message);
  @override
  List<Object> get props => [message];
}

// States untuk proses verifikasi OTP
class VerifyChangePhoneLoading extends ChangePhoneState {}
class VerifyChangePhoneSuccess extends ChangePhoneState {}
class VerifyChangePhoneFailure extends ChangePhoneState {
  final String message;
  const VerifyChangePhoneFailure(this.message);
  @override
  List<Object> get props => [message];
}