import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_state.dart';

// Impor use case Anda
// import 'package:menara/features/auth/domain/usecases/login_user_usecase.dart';
// import 'package:menara/features/auth/domain/usecases/logout_user_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Deklarasikan use case yang akan di-inject
  // final LoginUserUsecase loginUserUsecase;
  // final LogoutUserUsecase logoutUserUsecase;

  AuthBloc(
    // Terima use case melalui constructor
    // {
    //   required this.loginUserUsecase,
    //   required this.logoutUserUsecase,
    // }
  ) : super(AuthInitial()) {
    
    // Handler untuk LoginEvent
    on<LoginEvent>((event, emit) async {
      // 1. Keluarkan state loading agar UI bisa menampilkan progres
      emit(AuthLoading());

      // 2. Logika dummy (tanpa backend)
      // Tunggu 2 detik untuk simulasi panggilan jaringan
      await Future.delayed(const Duration(seconds: 2));

      // 3. Cek data dummy
      if (event.email == 'test@gmail.com' && event.password == '123456') {
        // Jika berhasil, keluarkan state success
        emit(AuthSuccess());
      } else {
        // Jika gagal, keluarkan state failure dengan pesan error
        emit(const AuthFailure(message: 'Email atau password salah!'));
      }

      /* // CONTOH JIKA SUDAH TERHUBUNG KE BACKEND (gunakan ini nanti)
      final result = await loginUserUsecase(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (user) => emit(AuthSuccess(user: user)),
      );
      */
    });

    // Handler untuk LogoutEvent
    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      // Logika untuk logout (misalnya, hapus token dari SharedPreferences)
      // await logoutUserUsecase();
      await Future.delayed(const Duration(seconds: 1)); // Simulasi
      emit(AuthInitial()); // Kembali ke state awal
    });
  }
}