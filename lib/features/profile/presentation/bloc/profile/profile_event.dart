part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

/// Event ini dipanggil saat pengguna menekan tombol "Save Changes"
class UpdateProfileButtonPressed extends ProfileEvent {
  final UserEntity user;
  final File? photoFile; // File gambar baru (opsional)

  const UpdateProfileButtonPressed({required this.user, this.photoFile});

  @override
  List<Object?> get props => [user, photoFile];
}

/// Event untuk memberitahu AuthBloc agar memperbarui datanya
class ProfileUpdated extends ProfileEvent {
  final UserEntity updatedUser;

  const ProfileUpdated(this.updatedUser);
  
  @override
  List<Object> get props => [updatedUser];
}
