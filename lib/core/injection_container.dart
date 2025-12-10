// File: core/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/features/home/domain/repositories/address_repository.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';
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
import 'package:nusantara_mobile/features/home/data/datasources/event_service.dart';
import 'package:nusantara_mobile/features/home/data/repositories/banner_repository_impl.dart';
import 'package:nusantara_mobile/features/home/data/repositories/category_repository_impl.dart';
import 'package:nusantara_mobile/features/home/data/repositories/event_repository_impl.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/banner_repository.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/category_repository.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/event_repository.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_all_banner_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/banner/get_banner_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_all_category_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_category_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/event/get_all_event_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/event/get_event_by_id_usecase.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_bloc.dart';
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

// --- Fitur: Cart ---
import 'package:nusantara_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:nusantara_mobile/features/cart/data/datasources/cart_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:nusantara_mobile/features/cart/domain/repositories/cart_repository.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/delete_cart_item_usecase.dart';
import 'package:nusantara_mobile/features/cart/domain/usecases/get_my_cart_usecase.dart';
import 'package:nusantara_mobile/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:nusantara_mobile/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:nusantara_mobile/features/favorite/data/datasources/favorite_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/favorite/data/repositories/favorite_repository_impl.dart';
import 'package:nusantara_mobile/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/add_to_favorite_usecase.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/get_my_favorite_usecase.dart';
import 'package:nusantara_mobile/features/favorite/domain/usecases/remove_from_favorite_usecase.dart';
import 'package:nusantara_mobile/features/favorite/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:nusantara_mobile/features/point/data/datasources/point_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/point/data/repositories/point_repository_impl.dart';
import 'package:nusantara_mobile/features/point/domain/repositories/point_repository.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_usecase.dart';
import 'package:nusantara_mobile/features/point/domain/usecases/get_customer_point_history_usecase.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_bloc.dart';

// --- Fitur: Shop ---
import 'package:nusantara_mobile/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:nusantara_mobile/features/shop/data/datasources/shop_remote_datasource_impl.dart';
import 'package:nusantara_mobile/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:nusantara_mobile/features/shop/domain/repositories/shop_repository.dart';
import 'package:nusantara_mobile/features/shop/domain/usecases/get_nearby_shops_usecase.dart';
import 'package:nusantara_mobile/features/shop/domain/usecases/get_shop_detail_usecase.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_bloc.dart';

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
    // debug: InjectionContainer: Creating AuthBloc singleton instance
    final authBloc = AuthBloc(
      checkPhoneUseCase: sl(),
      verifyPinAndLoginUseCase: sl(),
      registerUseCase: sl(),
      getLoggedInUserUseCase: sl(),
      logoutUserUseCase: sl(),
      forgotPinUseCase: sl(),
      localDatasource: sl(),
    );
    // debug: InjectionContainer: AuthBloc singleton created with hashCode: ${authBloc.hashCode}
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
  sl.registerFactory(() => AddressBloc(addressRepository: sl()));
  sl.registerFactory(
    () => EventBloc(getAllEventUsecase: sl(), getEventByIdUsecase: sl()),
  );

  // --- Usecases ---
  sl.registerLazySingleton(() => GetAllBannerUsecase(sl()));
  sl.registerLazySingleton(() => GetBannerByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetAllCategoryUsecase(sl()));
  sl.registerLazySingleton(() => GetCategoryByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetAllEventUsecase(sl()));
  sl.registerLazySingleton(() => GetEventByIdUsecase(sl()));

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
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(eventRemoteDatasource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<AddressRepository>(() => AddressRepository());

  // --- Datasources ---
  sl.registerLazySingleton<BannerRemoteDatasource>(
    () => BannerRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<EventRemoteDatasource>(
    () => EventRemoteDatasourceImpl(client: sl()),
  );

  // =======================================================
  //                       FITUR: VOUCHER
  // =======================================================
  // debug: Registering Voucher dependencies...

  // --- Bloc ---
  // Note: Menggunakan registerFactory untuk memastikan instance baru setiap kali
  sl.registerFactory(() {
    // debug: Creating NEW VoucherBloc instance...
    try {
      final bloc = VoucherBloc(
        getAllVoucherUsecase: sl(),
        getVoucherByIdUsecase: sl(),
        claimVoucherUsecase: sl(),
        getClaimedVouchersUsecase: sl(),
      );
      // debug: NEW VoucherBloc instance created successfully with initial state: ${bloc.state.runtimeType}
      return bloc;
    } catch (e) {
      // debug: Error creating VoucherBloc: $e
      rethrow;
    }
  });

  // --- Usecases ---
  sl.registerLazySingleton(() {
    // debug: Creating GetAllVoucherUsecase...
    try {
      final usecase = GetAllVoucherUsecase(sl());
      // debug: GetAllVoucherUsecase created successfully
      return usecase;
    } catch (e) {
      // debug: Error creating GetAllVoucherUsecase: $e
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    // debug: Creating GetVoucherByIdUsecase...
    try {
      final usecase = GetVoucherByIdUsecase(sl());
      // debug: GetVoucherByIdUsecase created successfully
      return usecase;
    } catch (e) {
      // debug: Error creating GetVoucherByIdUsecase: $e
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    // debug: Creating ClaimVoucherUsecase...
    try {
      final usecase = ClaimVoucherUsecase(sl());
      // debug: ClaimVoucherUsecase created successfully
      return usecase;
    } catch (e) {
      // debug: Error creating ClaimVoucherUsecase: $e
      rethrow;
    }
  });
  sl.registerLazySingleton(() {
    // debug: Creating GetClaimedVouchersUsecase...
    try {
      final usecase = GetClaimedVouchersUsecase(sl());
      // debug: GetClaimedVouchersUsecase created successfully
      return usecase;
    } catch (e) {
      // debug: Error creating GetClaimedVouchersUsecase: $e
      rethrow;
    }
  });

  // --- Repository ---
  sl.registerLazySingleton<VoucherRepository>(() {
    // debug: Creating VoucherRepository...
    try {
      final repo = VoucherRepositoryImpl(
        voucherRemoteDataSource: sl(),
        networkInfo: sl(),
      );
      // debug: VoucherRepository created successfully
      return repo;
    } catch (e) {
      // debug: Error creating VoucherRepository: $e
      rethrow;
    }
  });

  // <<< PERBAIKAN: Tambahkan registrasi VoucherRemoteDataSource yang hilang di sini >>>
  sl.registerLazySingleton<VoucherRemoteDataSource>(() {
    // debug: Creating VoucherRemoteDataSource...
    try {
      final dataSource = VoucherRemoteDataSourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          // Trigger AuthTokenExpired event via AuthBloc
          // debug: Token expired callback triggered
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            // debug: Error triggering token expired: $e
          }
        },
      );
      // debug: VoucherRemoteDataSource created successfully
      return dataSource;
    } catch (e) {
      // debug: Error creating VoucherRemoteDataSource: $e
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
    // debug: Creating PointRemoteDatasource...
    try {
      final dataSource = PointRemoteDatasourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          // Trigger AuthTokenExpired event via AuthBloc
          // debug: Token expired callback triggered from PointRemoteDatasource
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            // debug: Error triggering token expired: $e
          }
        },
      );
      // debug: PointRemoteDatasource created successfully
      return dataSource;
    } catch (e) {
      // debug: Error creating PointRemoteDatasource: $e
      rethrow;
    }
  });

  // =======================================================
  //                       FITUR: SHOP
  // =======================================================
  // --- Bloc ---
  sl.registerFactory(
    () => ShopBloc(getNearbyShopsUseCase: sl(), getShopDetailUseCase: sl()),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetNearbyShopsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopDetailUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      localDatasource: sl(),
    ),
  );

  // --- Datasources ---
  sl.registerLazySingleton<ShopRemoteDataSource>(() {
    try {
      final dataSource = ShopRemoteDataSourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            // debug: Error triggering token expired: $e
          }
        },
      );
      return dataSource;
    } catch (e) {
      rethrow;
    }
  });

  // =======================================================
  //                       FITUR: CART
  // =======================================================
  // --- Bloc ---
  // Register as LazySingleton agar semua page pakai instance yang sama
  sl.registerLazySingleton(
    () => CartBloc(
      getMyCartUseCase: sl(),
      addToCartUseCase: sl(),
      deleteCartItemUseCase: sl(),
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetMyCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCartItemUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // --- Datasources ---
  sl.registerLazySingleton<CartRemoteDataSource>(() {
    try {
      final dataSource = CartRemoteDataSourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            // debug: Error triggering token expired: $e
          }
        },
      );
      return dataSource;
    } catch (e) {
      rethrow;
    }
  });

  // =======================================================
  //                    FITUR: FAVORITE
  // =======================================================
  // --- Bloc ---
  // Register as LazySingleton agar semua page pakai instance yang sama
  sl.registerLazySingleton(
    () => FavoriteBloc(
      getMyFavoriteUseCase: sl(),
      addToFavoriteUseCase: sl(),
      removeFromFavoriteUseCase: sl(),
    ),
  );

  // --- Use Cases ---
  sl.registerLazySingleton(() => GetMyFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => AddToFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromFavoriteUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Datasources ---
  sl.registerLazySingleton<FavoriteRemoteDataSource>(() {
    try {
      final dataSource = FavoriteRemoteDataSourceImpl(
        client: sl(),
        localDatasource: sl(),
        onTokenExpired: () {
          try {
            final authBloc = sl<AuthBloc>();
            authBloc.add(const AuthTokenExpired());
          } catch (e) {
            // debug: Error triggering token expired: $e
          }
        },
      );
      return dataSource;
    } catch (e) {
      rethrow;
    }
  });
}
