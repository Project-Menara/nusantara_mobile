import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/forgot_pin_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/resend_code/resend_code_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_confirm_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/confirm_new_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/create_new_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_pin/change_pin_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/verify_pin/verify_pin_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// --- Core ---
import 'package:nusantara_mobile/core/network/network_info.dart';

// --- Fitur: Otentikasi (Authentication) ---
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin/pin_bloc.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logged_in/get_logged_in_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logout/logout_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code/verify_code_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/login/verify_pin_and_login_usecase.dart';
import 'package:nusantara_mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource_impl.dart';

// --- Fitur: Profile ---
import 'package:nusantara_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/request_change_phone_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_change_phone_usecase.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';

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
      forgotPinUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => OtpBloc(verifyCodeUseCase: sl(), resendCodeUseCase: sl()),
  );
  sl.registerFactory(
    () => PinBloc(
      createPinUseCase: sl(),
      confirmPinUseCase: sl(),
      setNewPinForgotUseCase: sl(),
      confirmNewPinForgotUseCase: sl(),
    ),
  );
  sl.registerFactory(() => HomeBloc());
  sl.registerFactory(() => VerifyPinBloc(verifyPinUsecase: sl()));

  sl.registerFactory(
    () => ProfileBloc(updateUserProfileUseCase: sl(), authBloc: sl()),
  );

  sl.registerFactory(
    () => ChangePinBloc(
      createNewPinUseCase: sl(),
      confirmNewPinUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // <<< BARU: Daftarkan ChangePhoneBloc >>>
  sl.registerFactory(
    () => ChangePhoneBloc(
      requestChangePhoneUseCase: sl(),
      verifyChangePhoneUseCase: sl(),
      authBloc: sl(),
    ),
  );

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
  sl.registerLazySingleton(() => ForgotPinUseCase(sl()));
  sl.registerLazySingleton(() => SetNewPinForgotUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmNewPinForgotUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateNewPinUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmNewPinUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPinUsecase(sl()));

  // <<< BARU: Daftarkan UseCase untuk Ubah Nomor Telepon >>>
  sl.registerLazySingleton(() => RequestChangePhoneUseCase(sl()));
  sl.registerLazySingleton(() => VerifyChangePhoneUseCase(sl()));

  // Repositories
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

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
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
