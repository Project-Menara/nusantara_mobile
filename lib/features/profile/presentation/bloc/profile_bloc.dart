import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // final ProfileRepository profileRepository; // Nanti diinjeksi dari domain layer

  ProfileBloc(/*{required this.profileRepository}*/) : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
  }

  Future<void> _onFetchProfileData(
    FetchProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Keluarkan state Loading
    emit(ProfileLoading());
    try {
      // 2. Simulasi penundaan jaringan
      await Future.delayed(const Duration(seconds: 1));

      // 3. Siapkan data palsu (mock data) untuk profil
      const mockProfile = ProfileEntity(
        name: 'rivael',
        email: 'rivael@gmail.com',
        photoUrl: 'https://i.pravatar.cc/150?img=56',
      );

      // 4. Jika berhasil, keluarkan state Loaded dengan data profil
      emit(const ProfileLoaded(profile: mockProfile));

    } catch (e) {
      // 5. Jika gagal, keluarkan state Error
      emit(ProfileError('Gagal memuat profil: ${e.toString()}'));
    }
  }
}