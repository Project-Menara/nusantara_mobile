import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

/// Event yang dikirim saat tombol "Next" ditekan
class OtpSubmitted extends OtpEvent {
  final String phoneNumber;
  final String code;

  const OtpSubmitted({required this.phoneNumber, required this.code});

  @override
  List<Object> get props => [phoneNumber, code];
}