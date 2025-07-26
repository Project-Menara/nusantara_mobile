part of 'pin_bloc.dart';

abstract class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object> get props => [];
}

class CreatePinSubmitted extends PinEvent {
  final String phoneNumber;
  final String pin;

  const CreatePinSubmitted({required this.phoneNumber, required this.pin});

  @override
  List<Object> get props => [phoneNumber, pin];
}