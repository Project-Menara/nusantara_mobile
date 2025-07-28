import 'package:equatable/equatable.dart';
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

// ✅ State khusus untuk Rate Limit, mewarisi dari AuthLoginFailure
class AuthLoginRateLimited extends AuthLoginFailure {
  final int retryAfterSeconds;
  
  // 'super(message)' meneruskan pesan error ke parent class (AuthLoginFailure)
  const AuthLoginRateLimited({
    required String message,
    required this.retryAfterSeconds,
  }) : super(message);
  
  @override
  List<Object> get props => [message, retryAfterSeconds];
}


//--- Register States ---//
class AuthRegisterSuccess extends AuthState {}

class AuthRegisterFailure extends AuthState {
  final String message;
  const AuthRegisterFailure(this.message);
  @override
  List<Object> get props => [message];
}

//--- Logout States ---//
class AuthLogoutSuccess extends AuthState {}

class AuthLogoutFailure extends AuthState {
  final String message;
  const AuthLogoutFailure(this.message);
  @override
  List<Object> get props => [message];
}