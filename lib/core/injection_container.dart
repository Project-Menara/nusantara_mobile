import 'package:get_it/get_it.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
// Impor lain yang dibutuhkan...

final sl = GetIt.instance;

void init() async {
  // =================================================================
  // FITUR: HOME
  // =================================================================
  // BLoC
  sl.registerFactory(() => HomeBloc(/* inject dependencies di sini jika ada, misal: sl() */));

  // Use cases
  // sl.registerLazySingleton(() => GetHomeDataUsecase(sl()));

  // Repository
  // sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));

  // ...dan seterusnya untuk semua dependensi Home...


  // =================================================================
  // FITUR: OTENTIKASI (Authentication) - Pastikan tidak di-comment
  // =================================================================
  // ... (registrasi AuthBloc dan dependensinya)


  // =================================================================
  // CORE & EXTERNAL - Pastikan tidak di-comment
  // =================================================================
  // ... (registrasi NetworkInfo, SharedPreferences, dll.)
}