part of 'pin_bloc.dart';

abstract class PinState extends Equatable {
  const PinState();

  @override
  List<Object> get props => [];
}

class PinInitial extends PinState {}

class PinCreationLoading extends PinState {}

class PinCreationSuccess extends PinState {}

class PinCreationFailure extends PinState {
  final String message;

  const PinCreationFailure(this.message);

  @override
  List<Object> get props => [message];
}