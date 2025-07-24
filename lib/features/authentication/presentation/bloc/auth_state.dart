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

/// State jika terjadi kegagalan pada salah satu proses otentikasi.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

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

/// State sukses setelah verifikasi PIN berhasil.
/// Membawa data lengkap pengguna.
class AuthLoginSuccess extends AuthState {
  final UserEntity user;

  const AuthLoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

/// State sukses setelah registrasi berhasil.
class AuthRegisterSuccess extends AuthState {}

/// State sukses setelah logout berhasil.
class AuthLogoutSuccess extends AuthState {}