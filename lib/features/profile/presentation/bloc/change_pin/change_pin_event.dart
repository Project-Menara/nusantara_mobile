part of 'change_pin_bloc.dart';

abstract class ChangePinEvent extends Equatable {
  const ChangePinEvent();
  @override
  List<Object?> get props => [];
}

/// Event saat pengguna mengirim PIN baru
class CreatePinSubmitted extends ChangePinEvent {
  final String newPin;
  const CreatePinSubmitted({required this.newPin});
  @override
  List<Object?> get props => [newPin];
}

/// Event saat pengguna mengirim konfirmasi PIN
class ConfirmPinSubmitted extends ChangePinEvent {
  final String confirmPin;
  const ConfirmPinSubmitted({required this.confirmPin});
  @override
  List<Object?> get props => [confirmPin];
}