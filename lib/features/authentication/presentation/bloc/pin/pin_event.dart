part of 'pin_bloc.dart';

abstract class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object> get props => [];
}

// <<< TAMBAHAN EVENT UNTUK VALIDASI TOKEN >>>
class ValidateForgotPinToken extends PinEvent {
  final String token;
  const ValidateForgotPinToken({required this.token});

  @override
  List<Object> get props => [token];
}

class CreatePinSubmitted extends PinEvent {
  final String phoneNumber;
  final String pin;

  const CreatePinSubmitted({required this.phoneNumber, required this.pin});

  @override
  List<Object> get props => [phoneNumber, pin];
}

class ConfirmPinSubmitted extends PinEvent {
  final String phoneNumber;
  final String pin;

  const ConfirmPinSubmitted({required this.phoneNumber, required this.pin});

  @override
  List<Object> get props => [phoneNumber, pin];
}

class SetNewPinForgotSubmitted extends PinEvent {
  final String token;
  final String phoneNumber;
  final String pin;

  const SetNewPinForgotSubmitted({
    required this.token,
    required this.phoneNumber,
    required this.pin,
  });
  @override
  List<Object> get props => [token, phoneNumber, pin];
}

class ConfirmNewPinForgotSubmitted extends PinEvent {
  final String token;
  final String phoneNumber;
  final String pin;

  const ConfirmNewPinForgotSubmitted({
    required this.token,
    required this.phoneNumber,
    required this.pin,
  });
  @override
  List<Object> get props => [token, phoneNumber, pin];
}