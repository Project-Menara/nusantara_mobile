import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart'; // Untuk mengakses AuthBloc
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart'; // Untuk event AuthUserUpdated

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // 1. Definisikan UseCase yang dibutuhkan
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  // 2. Tambahkan AuthBloc untuk komunikasi antar BLoC
  final AuthBloc authBloc;

  // 3. Injeksi UseCase dan AuthBloc melalui constructor
  ProfileBloc({required this.updateUserProfileUseCase, required this.authBloc})
    : super(ProfileInitial()) {
    // 4. Daftarkan event handler
    on<UpdateProfileButtonPressed>(_onUpdateProfileButtonPressed);
  }

  // 5. Implementasikan handler untuk event
  Future<void> _onUpdateProfileButtonPressed(
    UpdateProfileButtonPressed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final params = UpdateUserParams(
      user: event.user,
      photoFile: event.photoFile,
    );
    final result = await updateUserProfileUseCase(params);

    result.fold((failure) => emit(ProfileUpdateFailure(failure.message)), (
      updatedUser,
    ) {
      // Jika sukses, keluarkan state sukses
      emit(ProfileUpdateSuccess(updatedUser));
      // Beri tahu AuthBloc bahwa data user telah diperbarui
      authBloc.add(AuthUserUpdated(updatedUser));
    });
  }
}
