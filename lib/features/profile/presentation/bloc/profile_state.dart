part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final UserEntity updatedUser;
  const ProfileUpdateSuccess(this.updatedUser);
  @override
  List<Object> get props => [updatedUser];
}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  const ProfileUpdateFailure(this.message);
  @override
  List<Object> get props => [message];
}
class AuthUserUpdated extends AuthEvent {
  final UserEntity updatedUser;

  const AuthUserUpdated(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}