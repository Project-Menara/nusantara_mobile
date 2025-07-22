import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event saat pengguna menekan tombol login
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Event saat pengguna menekan tombol logout
class LogoutEvent extends AuthEvent {}

// Event untuk mengecek status login saat aplikasi dimulai (opsional, jika pakai Splash)
class CheckAuthStatusEvent extends AuthEvent {}