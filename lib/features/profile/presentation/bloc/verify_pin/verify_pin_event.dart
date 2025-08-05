// lib/features/profile/presentation/bloc/verify_pin/verify_pin_event.dart

part of 'verify_pin_bloc.dart';

abstract class VerifyPinEvent extends Equatable {
  const VerifyPinEvent();

  @override
  List<Object> get props => [];
}

/// Event yang dipicu ketika pengguna mengirimkan PIN untuk diverifikasi.
class VerifyPinSubmitted extends VerifyPinEvent {
  final String pin;

  const VerifyPinSubmitted({required this.pin});

  @override
  List<Object> get props => [pin];
}