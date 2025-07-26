import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/network/network_info.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_pin_and_login_usecase.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin_bloc.dart'; // <-- Impor PinBloc
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =================================================================
  // FITUR: OTENTIKASI (Authentication)
  // =================================================================

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      checkPhoneUseCase: sl<CheckPhoneUseCase>(),
      verifyPinAndLoginUseCase: sl<VerifyPinAndLoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );

  sl.registerFactory(
    () => OtpBloc(
      verifyCodeUseCase: sl<VerifyCodeUseCase>(),
    ),
  );
  
  // =================================================================
  // FITUR: PIN
  // =================================================================
  
  // BLoC
  sl.registerFactory(
    () => PinBloc(
      createPinUseCase: sl<CreatePinUseCase>(),
      confirmPinUseCase: sl<ConfirmPinUseCase>(),
    ),
  );

  // =================================================================
  // UseCases (untuk semua fitur)
  // =================================================================
  sl.registerLazySingleton(() => CheckPhoneUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyPinAndLoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CreatePinUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ConfirmPinUseCase(sl<AuthRepository>()));


  // =================================================================
  // Repositories & DataSources (untuk semua fitur)
  // =================================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl<AuthRemoteDataSource>(),
      localDatasource: sl<LocalDatasource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () =>
        AuthRemoteDataSourceImpl(sl<NetworkInfo>(), client: sl<http.Client>()),
  );

  sl.registerLazySingleton<LocalDatasource>(
    () => LocalDatasourceImpl(sl<SharedPreferences>()),
  );

  // =================================================================
  // FITUR: HOME
  // =================================================================
  sl.registerFactory(() => HomeBloc());

  // =================================================================
  // CORE & EXTERNAL
  // =================================================================
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}