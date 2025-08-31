// File: core/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/features/home/presentation/bloc/banner_detail/banner_detail_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// --- Core ---
import 'package:nusantara_mobile/core/network/network_info.dart';

// --- Fitur: Otentikasi (Authentication) ---
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource_impl.dart';
import 'package:nusantara_mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:nusantara_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/check_phone/check_phone_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin/create_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/forgot_pin_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_confirm_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/set_new_pin_forgot_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/forgot_pin/validate_forgot_pin_token_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logged_in/get_logged_in_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/login/verify_pin_and_login_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/logout/logout_user_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/register/register_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/resend_code/resend_code_usecase.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/verify_code/verify_code_use_case.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin/pin_bloc.dart';

// --- Fitur: Home ---
import 'package:nusantara_mobile/features/home/data/dataSource/banner_remote_dataSource.dart';
import 'package:nusantara_mobile/features/home/data/dataSource/category_remote_dataSource.dart';
import 'package:nusantara_mobile/features/home/data/repositories/banner_repository_impl.dart';
import 'package:nusantara_mobile/features/home/data/repositories/category_repository_impl.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/banner_repository.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/category_repository.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_all_banner_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_banner_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_all_category_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_category_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';

// --- Fitur: Profile ---
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:nusantara_mobile/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:nusantara_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nusantara_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/confirm_new_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/create_new_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/request_change_phone_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_change_phone_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_pin/change_pin_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/verify_pin/verify_pin_bloc.dart';

// <<< BARU: Import untuk Voucher >>>
import 'package:nusantara_mobile/features/voucher/data/datasources/voucher_remote_data_source.dart';
import 'package:nusantara_mobile/features/voucher/data/repositories/voucher_repository_impl.dart';
import 'package:nusantara_mobile/features/voucher/domain/repositories/voucher_repository.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_all_voucher_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_voucher_by_id_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/claim_voucher_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_claimed_vouchers_usecase.dart';
import 'package:nusantara_mobile/features/voucher/presentation/bloc/voucher/voucher_bloc.dart';

// --- Fitur: Point ---
import 'package:nusantara_mobile/features/point/data/datasources/point_remote_datasource.dart';
import 'package:nusantara_mobile/features/point/data/datasources/point_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/point/data/repositories/point_repository_impl.dart';
import 'package:nusantara_mobile/features/point/domain/repositories/point_repository.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_usecase.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_history_usecase.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =======================================================
  //                       EXTERNAL & CORE
  // =======================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // --- Shared Dependencies ---
  sl.registerLazySingleton<LocalDatasource>(() => LocalDatasourceImpl(sl()));

  // =======================================================
  //               FITUR: OTENTIKASI (AUTHENTICATION)
  // =======================================================
  // --- Bloc ---
  // PERBAIKAN: Gunakan registerLazySingleton untuk AuthBloc agar state tidak hilang
  sl.registerLazySingleton(() {
    print("🏭 InjectionContainer: Creating AuthBloc singleton instance");
    final authBloc = AuthBloc(
      checkPhoneUseCase: sl(),
      verifyPinAndLoginUseCase: sl(),
      registerUseCase: sl(),
      getLoggedInUserUseCase: sl(),
      logoutUserUseCase: sl(),
      forgotPinUseCase: sl(),
      localDatasource: sl(),
    );
    print(
      "🏭 InjectionContainer: AuthBloc singleton created with hashCode: ${authBloc.hashCode}",
    );
    return authBloc;
  });
  sl.registerFactory(
    () => OtpBloc(verifyCodeUseCase: sl(), resendCodeUseCase: sl()),
  );
  sl.registerFactory(
    () => PinBloc(
      createPinUseCase: sl(),
      confirmPinUseCase: sl(),
      setNewPinForgotUseCase: sl(),
      confirmNewPinForgotUseCase: sl(),
      validateForgotPinTokenUseCase: sl(),
    ),
  );

  // --- Usecases ---
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
  sl.registerLazySingleton(() => ValidateForgotPinTokenUseCase(sl()));
  sl.registerLazySingleton(() => SetNewPinForgotUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmNewPinForgotUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // --- Datasources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // =======================================================
  //                       FITUR: HOME
  // =======================================================
  // --- Bloc ---
  sl.registerFactory(() => HomeBloc());
  sl.registerFactory(
    () => BannerBloc(getAllBannerUsecase: sl(), getBannerByIdUsecase: sl()),
  );
  sl.registerFactory(
    () =>
        CategoryBloc(getAllCategoryUsecase: sl(), getCategoryByIdUsecase: sl()),
  );
  sl.registerFactory(() => BannerDetailBloc(getBannerByIdUseCase: sl()));

  // --- Usecases ---
  sl.registerLazySingleton(() => GetAllBannerUsecase(sl()));
  sl.registerLazySingleton(() => GetBannerByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetAllCategoryUsecase(sl()));
  sl.registerLazySingleton(() => GetCategoryByIdUsecase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(bannerRemoteDatasource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      categoryRemoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // --- Datasources ---
  sl.registerLazySingleton<BannerRemoteDatasource>(
    () => BannerRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImpl(client: sl()),
  );

  // =======================================================
  //                       FITUR: VOUCHER
  // =======================================================
  print("🔧 Registering Voucher dependencies...");

  // --- Bloc ---
  // Note: Menggunakan registerFactory untuk memastikan instance baru setiap kali
  sl.registerFactory(() {
    print("🔧 Creating NEW VoucherBloc instance...");
    try {
      final bloc = VoucherBloc(
        getAllVoucherUsecase: sl(),
        getVoucherByIdUsecase: sl(),
        claimVoucherUsecase: sl(),
        getClaimedVouchersUsecase: sl(),
      );
      print(
        "✅ NEW VoucherBloc instance created successfully with initial state: ${bloc.state.runtimeType}",
      );
      return bloc;
    } catch (e) {
      print("❌ Error creating VoucherBloc: $e");
      rethrow;
    }
  });

  // --- Usecases ---
  sl.registerLazySingleton(() {
    print("🔧 Creating GetAllVoucherUsecase...");
    try {
      final usecase = GetAllVoucherUsecase(sl());
      print("✅ GetAllVoucherUsecase created successfully");
      return usecase;
    } catch (e) {
      print("❌ Error creating GetAllVoucherUsecase: $e");
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    print("🔧 Creating GetVoucherByIdUsecase...");
    try {
      final usecase = GetVoucherByIdUsecase(sl());
      print("✅ GetVoucherByIdUsecase created successfully");
      return usecase;
    } catch (e) {
      print("❌ Error creating GetVoucherByIdUsecase: $e");
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    print("🔧 Creating ClaimVoucherUsecase...");
    try {
      final usecase = ClaimVoucherUsecase(sl());
      print("✅ ClaimVoucherUsecase created successfully");
      return usecase;
    } catch (e) {
      print("❌ Error creating ClaimVoucherUsecase: $e");
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    print("🔧 Creating GetClaimedVouchersUsecase...");
    try {
      final usecase = GetClaimedVouchersUsecase(sl());
      print("✅ GetClaimedVouchersUsecase created successfully");
      return usecase;
    } catch (e) {
      print("❌ Error creating GetClaimedVouchersUsecase: $e");
      rethrow;
    }
  });

  // --- Repository ---
  sl.registerLazySingleton<VoucherRepository>(() {
    print("🔧 Creating VoucherRepository...");
    try {
      final repo = VoucherRepositoryImpl(
        voucherRemoteDataSource: sl(),
        networkInfo: sl(),
      );
      print("✅ VoucherRepository created successfully");
      return repo;
    } catch (e) {
      print("❌ Error creating VoucherRepository: $e");
      rethrow;
    }
  });

  // <<< PERBAIKAN: Tambahkan registrasi VoucherRemoteDataSource yang hilang di sini >>>
  sl.registerLazySingleton<VoucherRemoteDataSource>(() {
    print("🔧 Creating VoucherRemoteDataSource...");
    try {
      final dataSource = VoucherRemoteDataSourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          // Trigger AuthTokenExpired event via AuthBloc
          print("🔐 Token expired callback triggered");
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            print("❌ Error triggering token expired: $e");
          }
        },
      );
      print("✅ VoucherRemoteDataSource created successfully");
      return dataSource;
    } catch (e) {
      print("❌ Error creating VoucherRemoteDataSource: $e");
      rethrow;
    }
  });

  // =======================================================
  //                       FITUR: PROFILE
  // =======================================================
  // --- Bloc ---
  sl.registerFactory(
    () => ProfileBloc(updateUserProfileUseCase: sl(), authBloc: sl()),
  );
  sl.registerFactory(() => VerifyPinBloc(verifyPinUsecase: sl()));
  sl.registerFactory(
    () => ChangePinBloc(
      createNewPinUseCase: sl(),
      confirmNewPinUseCase: sl(),
      authBloc: sl(),
    ),
  );
  sl.registerFactory(
    () => ChangePhoneBloc(
      requestChangePhoneUseCase: sl(),
      verifyChangePhoneUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // --- Usecases ---
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateNewPinUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmNewPinUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPinUsecase(sl()));
  sl.registerLazySingleton(() => RequestChangePhoneUseCase(sl()));
  sl.registerLazySingleton(() => VerifyChangePhoneUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileRemoteDataSource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // --- Datasources ---
  // --- Datasources ---
  // <<< PERBAIKAN: Membuat panggilan konsisten dengan menambahkan `client:` >>>
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // =======================================================
  //                       FITUR: POINT
  // =======================================================
  // --- Bloc ---
  sl.registerFactory(
    () => PointBloc(
      getCustomerPointUseCase: sl(),
      getCustomerPointHistoryUseCase: sl(),
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetCustomerPointUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerPointHistoryUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<PointRepository>(
    () => PointRepositoryImpl(remoteDatasource: sl(), networkInfo: sl()),
  );

  // --- Datasources ---
  sl.registerLazySingleton<PointRemoteDatasource>(() {
    print("🔧 Creating PointRemoteDatasource...");
    try {
      final dataSource = PointRemoteDatasourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          // Trigger AuthTokenExpired event via AuthBloc
          print(
            "🔐 Token expired callback triggered from PointRemoteDatasource",
          );
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            print("❌ Error triggering token expired: $e");
          }
        },
      );
      print("✅ PointRemoteDatasource created successfully");
      return dataSource;
    } catch (e) {
      print("❌ Error creating PointRemoteDatasource: $e");
      rethrow;
    }
  });
}
