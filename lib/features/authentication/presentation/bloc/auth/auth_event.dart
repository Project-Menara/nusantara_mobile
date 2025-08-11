import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckPhonePressed extends AuthEvent {
  final String phoneNumber;
  const AuthCheckPhonePressed(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

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

class GetUserEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthRegisterPressed extends AuthEvent {
  final RegisterEntity registerEntity;

  const AuthRegisterPressed(this.registerEntity);
  @override
  List<Object> get props => [registerEntity];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthForgotPinRequested extends AuthEvent {
  final String phoneNumber;

  const AuthForgotPinRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthLoggedIn extends AuthEvent {
  final UserEntity user;

  const AuthLoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUserUpdated extends AuthEvent {
  final UserEntity newUser;

  const AuthUserUpdated(this.newUser);

  @override
  List<Object> get props => [newUser];
}
