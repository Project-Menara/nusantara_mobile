import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

/// Event saat pengguna menekan tombol 'Lanjutkan' untuk mengecek nomor telepon.
class AuthCheckPhonePressed extends AuthEvent {
  final String phoneNumber;
  const AuthCheckPhonePressed(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

/// Event saat pengguna memasukkan PIN untuk login.
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

/// Event saat pengguna menekan tombol 'Create Account' di halaman registrasi.
class AuthRegisterPressed extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;

  const AuthRegisterPressed({
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