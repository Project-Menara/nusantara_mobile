part of 'profile_bloc.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String photoUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  @override
  List<Object> get props => [name, email, photoUrl];
}
// ------------------------------------

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

/// State awal saat BLoC pertama kali dibuat.
class ProfileInitial extends ProfileState {}

/// State saat BLoC sedang memuat data.
class ProfileLoading extends ProfileState {}

/// State saat data profil berhasil dimuat.
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// State saat terjadi kegagalan dalam memuat data.
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}