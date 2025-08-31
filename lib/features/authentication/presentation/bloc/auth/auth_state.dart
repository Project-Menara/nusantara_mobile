import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];

  get user => null;
}

class AuthInitial extends AuthState {}

class AuthCheckPhoneLoading extends AuthState {}

class AuthRegisterLoading extends AuthState {}

class AuthLoginLoading extends AuthState {}

class AuthForgotPinLoading extends AuthState {}

class AuthGetProfileLoading extends AuthState {}

// --- ---

class AuthUnauthenticated extends AuthState {}

// --- State Sukses ---
class AuthCheckPhoneSuccess extends AuthState {
  final PhoneCheckEntity result;
  const AuthCheckPhoneSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class AuthRegisterSuccess extends AuthState {
  final RegisterResponseModel user;
  const AuthRegisterSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthLoginSuccess extends AuthState {
  final UserEntity user;
  const AuthLoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthGetUserSuccess extends AuthState {
  final UserEntity user;
  const AuthGetUserSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthForgotPinSuccess extends AuthState {
  final String token;
  const AuthForgotPinSuccess(this.token);
  @override
  List<Object?> get props => [token];
}

// --- State Gagal ---
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLogoutFailure extends AuthState {
  final String message;
  const AuthLogoutFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCheckPhoneFailure extends AuthState {
  final String message;
  const AuthCheckPhoneFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthRegisterFailure extends AuthState {
  final String message;
  const AuthRegisterFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLoginFailure extends AuthState {
  final String message;
  const AuthLoginFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLoginRateLimited extends AuthLoginFailure {
  final int retryAfterSeconds;
  const AuthLoginRateLimited({
    required String message,
    required this.retryAfterSeconds,
  }) : super(message);
  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

class AuthForgotPinFailure extends AuthState {
  final String message;
  const AuthForgotPinFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthUpdateSuccess extends AuthState {
  final UserEntity user;

  const AuthUpdateSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthTokenExpiredState extends AuthState {
  final String message;

  const AuthTokenExpiredState({
    this.message = 'Token sudah kedaluwarsa. Silakan login kembali.',
  });

  @override
  List<Object> get props => [message];
}
