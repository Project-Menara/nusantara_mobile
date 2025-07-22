import 'package:equatable/equatable.dart';
// Jika Anda punya entitas User, impor di sini
// import 'package:menara/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// State awal atau saat belum ada aksi
class AuthInitial extends AuthState {}

// State saat sedang memproses (misalnya, loading saat login)
class AuthLoading extends AuthState {}

// State jika pengguna berhasil login
class AuthSuccess extends AuthState {
  // Anda bisa menyimpan data user di sini jika perlu
  // final User user;
  // const AuthSuccess({required this.user});
  // @override
  // List<Object> get props => [user];
}

// State jika terjadi error
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// State jika pengguna belum login (opsional, jika pakai Splash)
class AuthUnauthenticated extends AuthState {}