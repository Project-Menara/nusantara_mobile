import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

/// Event saat pengguna menekan tombol 'Lanjutkan' di halaman login awal.
/// Membawa data nomor telepon yang diinput.
class AuthCheckPhonePressed extends AuthEvent {
  final String phoneNumber;
  const AuthCheckPhonePressed(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

/// Event saat pengguna memasukkan PIN dan menekan tombol verifikasi.
class AuthVerifyPinPressed extends AuthEvent {
  final String phoneNumber;
  final String pin;
  const AuthVerifyPinPressed({required this.phoneNumber, required this.pin});
  @override
  List<Object> get props => [phoneNumber, pin];
}

/// Event saat pengguna menekan tombol 'Create Account' di halaman registrasi.
class AuthRegisterPressed extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;

  AuthRegisterPressed({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
  });
  @override
  List<Object> get props => [name, username, email, phone, gender];
}

/// Event saat pengguna menekan tombol logout.
class AuthLogoutPressed extends AuthEvent {}

class AuthLoginWithPinSubmitted extends AuthEvent {
  final String phoneNumber;
  final String pin;

  const AuthLoginWithPinSubmitted({
    required this.phoneNumber,
    required this.pin,
  });

  @override
  List<Object> get props => [phoneNumber, pin];
}
