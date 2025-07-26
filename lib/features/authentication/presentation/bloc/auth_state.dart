import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// State awal saat BLoC pertama kali dibuat.
class AuthInitial extends AuthState {}

/// State saat proses asynchronous sedang berjalan (menampilkan loading indicator).
class AuthLoading extends AuthState {}

// ========================================================
// SPESIFIC SUCCESS STATES (State Sukses yang Lebih Spesifik)
// ========================================================

/// State sukses setelah mengecek nomor telepon.
/// Membawa data `action` ('login' atau 'register').
class AuthCheckPhoneSuccess extends AuthState {
  final PhoneCheckEntity result;

  const AuthCheckPhoneSuccess(this.result);

  @override
  List<Object> get props => [result];
}

/// State gagal saat mengecek nomor telepon.
class AuthCheckPhoneFailure extends AuthState {
  final String message;

  const AuthCheckPhoneFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// State sukses setelah verifikasi PIN berhasil.
/// Membawa data lengkap pengguna.
class AuthLoginSuccess extends AuthState {
  final UserEntity user;

  const AuthLoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

/// State gagal saat login.
class AuthLoginFailure extends AuthState {
  final String message;

  const AuthLoginFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// State sukses setelah registrasi berhasil.
class AuthRegisterSuccess extends AuthState {}

/// State gagal saat registrasi.
class AuthRegisterFailure extends AuthState {
  final String message;

  const AuthRegisterFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// State sukses setelah logout berhasil.
class AuthLogoutSuccess extends AuthState {}

/// State gagal saat logout.
class AuthLogoutFailure extends AuthState {
  final String message;

  const AuthLogoutFailure(this.message);

  @override
  List<Object> get props => [message];
}
