part of 'change_pin_bloc.dart';

abstract class ChangePinState extends Equatable {
  const ChangePinState();
  @override
  List<Object> get props => [];
}

class ChangePinInitial extends ChangePinState {}

// States untuk proses pembuatan PIN baru
class CreatePinLoading extends ChangePinState {}
class CreatePinSuccess extends ChangePinState {}
class CreatePinFailure extends ChangePinState {
  final String message;
  const CreatePinFailure(this.message);
  @override
  List<Object> get props => [message];
}

// States untuk proses konfirmasi PIN
class ConfirmPinLoading extends ChangePinState {}
class ConfirmPinSuccess extends ChangePinState {
  final UserEntity updatedUser;
  const ConfirmPinSuccess(this.updatedUser);
  @override
  List<Object> get props => [updatedUser];
}
class ConfirmPinFailure extends ChangePinState {
  final String message;
  const ConfirmPinFailure(this.message);
  @override
  List<Object> get props => [message];
}