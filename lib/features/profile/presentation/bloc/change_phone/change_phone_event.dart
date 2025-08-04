part of 'change_phone_bloc.dart';

abstract class ChangePhoneEvent extends Equatable {
  const ChangePhoneEvent();
  @override
  List<Object?> get props => [];
}

/// Event saat pengguna mengirim nomor telepon baru untuk meminta OTP
class RequestChangePhoneSubmitted extends ChangePhoneEvent {
  final String newPhone;
  const RequestChangePhoneSubmitted({required this.newPhone});
  @override
  List<Object?> get props => [newPhone];
}

/// Event saat pengguna mengirim OTP untuk verifikasi
class VerifyChangePhoneSubmitted extends ChangePhoneEvent {
  final String phone;
  final String code;
  const VerifyChangePhoneSubmitted({required this.phone, required this.code});
  @override
  List<Object?> get props => [phone, code];
}