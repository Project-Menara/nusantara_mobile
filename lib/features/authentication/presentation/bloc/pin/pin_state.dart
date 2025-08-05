part of 'pin_bloc.dart';

abstract class PinState extends Equatable {
  const PinState();

  @override
  List<Object> get props => [];
}

class PinInitial extends PinState {}
class PinLoading extends PinState {}

// <<< TAMBAHAN STATE UNTUK VALIDASI TOKEN >>>
class ResetTokenValidationLoading extends PinState {}
class ResetTokenValid extends PinState {}
class ResetTokenInvalid extends PinState {
  final String message;
  const ResetTokenInvalid(this.message);
  @override
  List<Object> get props => [message];
}

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

class SetNewPinForgotTokenExpired extends PinState {
  final String message;
  const SetNewPinForgotTokenExpired(this.message);
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

// <<< TAMBAHAN STATE (DARI PERCAKAPAN SEBELUMNYA, UNTUK KONSISTENSI) >>>
class ConfirmNewPinForgotTokenExpired extends PinState {
  final String message;
  const ConfirmNewPinForgotTokenExpired(this.message);
  @override
  List<Object> get props => [message];
}