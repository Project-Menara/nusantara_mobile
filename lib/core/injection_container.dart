import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/features/authentication/domain/usecases/resend_code_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// --- Core ---
import 'package:nusantara_mobile/core/network/network_info.dart';

// --- Fitur: Otentikasi (Authentication) ---
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin/pin_bloc.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logout_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_pin_and_login_usecase.dart';
import 'package:nusantara_mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource_impl.dart';

// --- Fitur: Profile (PENTING UNTUK LOGOUT) ---
import 'package:nusantara_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source_impl.dart';

// --- Fitur: Home ---
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerLazySingleton(
    () => AuthBloc(
      checkPhoneUseCase: sl(),
      verifyPinAndLoginUseCase: sl(),
      registerUseCase: sl(),
      getLoggedInUserUseCase: sl(),
      logoutUserUseCase: sl(),
    ),
  );
sl.registerFactory(() => OtpBloc(
  verifyCodeUseCase: sl(),
  resendCodeUseCase: sl(), // <-- Tambahkan ini
));
  sl.registerFactory(
    () => PinBloc(createPinUseCase: sl(), confirmPinUseCase: sl()),
  );
  sl.registerFactory(() => HomeBloc());

  // UseCases
  sl.registerLazySingleton(() => GetLoggedInUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckPhoneUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPinAndLoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => CreatePinUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmPinUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl()));
  sl.registerLazySingleton(() => ResendCodeUseCase(sl()));

  // Repositories & DataSources
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileRemoteDataSource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // <<< PASTIKAN PEMANGGILAN DI SINI BENAR (TANPA client:) >>>
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  // <<< PASTIKAN PEMANGGILAN DI SINI BENAR (TANPA client:) >>>
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocalDatasource>(() => LocalDatasourceImpl(sl()));

  // CORE & EXTERNAL
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}
