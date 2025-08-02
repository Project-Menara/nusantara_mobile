part of 'pin_bloc.dart';

// Import UserModel karena akan digunakan di state sukses

abstract class PinState extends Equatable {
  const PinState();

  @override
  List<Object> get props => [];
}

class PinInitial extends PinState {}

class PinLoading extends PinState {}

class PinCreationSuccess extends PinState {}

class PinCreationError extends PinState {
  final String message;

  const PinCreationError(this.message);

  @override
  List<Object> get props => [message];
}

class PinConfirmationSuccess extends PinState {
  final UserModel user;

  const PinConfirmationSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class PinConfirmationError extends PinState {
  final String message;

  const PinConfirmationError(this.message);

  @override
  List<Object> get props => [message];
}

class SetNewPinForgotSuccess extends PinState {}

class SetNewPinForgotError extends PinState {
  final String message;
  const SetNewPinForgotError(this.message);
  @override
  List<Object> get props => [message];
}

class ConfirmNewPinForgotSuccess extends PinState {
  final UserModel user;
  const ConfirmNewPinForgotSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class ConfirmNewPinForgotError extends PinState {
  final String message;
  const ConfirmNewPinForgotError(this.message);
  @override
  List<Object> get props => [message];
}
