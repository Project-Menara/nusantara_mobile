import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

//--- Phone Check States ---//
class AuthCheckPhoneSuccess extends AuthState {
  final PhoneCheckEntity result;
  const AuthCheckPhoneSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class AuthCheckPhoneFailure extends AuthState {
  final String message;
  const AuthCheckPhoneFailure(this.message);
  @override
  List<Object> get props => [message];
}

//--- Login States ---//
class AuthLoginSuccess extends AuthState {
  final UserEntity user;
  const AuthLoginSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class AuthLoginFailure extends AuthState {
  final String message;
  const AuthLoginFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthLoginRateLimited extends AuthLoginFailure {
  final int retryAfterSeconds;

  const AuthLoginRateLimited({
    required String message,
    required this.retryAfterSeconds,
  }) : super(message);

  @override
  List<Object> get props => [message, retryAfterSeconds];
}

class AuthRegisterSuccess extends AuthState {
  final RegisterResponseModel user;

  const AuthRegisterSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthRegisterFailure extends AuthState {
  final String message;
  const AuthRegisterFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthLogoutSuccess extends AuthState {}

class AuthLogoutFailure extends AuthState {
  final String message;
  const AuthLogoutFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthGetUserSuccess extends AuthState {
  final UserEntity user;
  const AuthGetUserSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class AuthGetUserFailure extends AuthState {
  final String message;
  const AuthGetUserFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthUnauthenticated extends AuthState {}
