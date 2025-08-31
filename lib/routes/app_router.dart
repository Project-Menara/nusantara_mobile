import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/core/presentation/main_screen.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/forgot_pin_extra.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_extra.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/forgot_pin/confirm_forgot_pin_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/create_pin/confirm_pin_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/create_pin/create_pin_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/forgot_pin/forgot_pin_new_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/login/login_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/login/pin_login_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/register/register_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/otp/verify_number.dart';
import 'package:nusantara_mobile/features/favorite/presentation/pages/favorite/favorites_page.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/banner/banner_detail_page.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/home_page.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_1.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_2.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_3.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/change_phone/change_phone_page.dart'
    as change_phone;
import 'package:nusantara_mobile/features/profile/presentation/pages/change_phone/verify_change_phone_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/my_voucher/my_voucher_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/voucher_detail/voucher_detail_page.dart'
    as profile_voucher_detail;
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/point/presentation/pages/point_history_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/personal_data/personal_data_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/profil/profile_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/verify_pin/verify_pin_for_changephone_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/verify_pin/verify_pin_for_changepin_page.dart';

import 'package:nusantara_mobile/features/splash_screen/splash_screen.dart';
import 'package:nusantara_mobile/features/voucher/presentation/pages/voucher/voucher_page.dart';
import 'package:nusantara_mobile/features/voucher/presentation/pages/voucher_detail/voucher_detail_index.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// <<< BARU: Impor halaman ubah PIN >>>
import 'package:nusantara_mobile/features/profile/presentation/pages/change_pin/change_pin_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/change_pin/confirm_change_pin_page.dart';

// <<< BARU: Impor halaman orders >>>
import 'package:nusantara_mobile/features/orders/presentation/pages/orders_page.dart';
import 'package:nusantara_mobile/features/orders/presentation/pages/order_detail_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRoute = GoRouter(
  initialLocation: InitialRoutes.splashScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    // --- RUTE-RUTE TANPA NAVBAR ---
    GoRoute(
      path: InitialRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: InitialRoutes.onboarding1,
      builder: (context, state) => const OnboardingScreen1(),
    ),
    GoRoute(
      path: InitialRoutes.onboarding2,
      builder: (context, state) => const OnboardingScreen2(),
    ),
    GoRoute(
      path: InitialRoutes.onboarding3,
      builder: (context, state) => const OnboardingScreen3(),
    ),
    GoRoute(
      path: InitialRoutes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: InitialRoutes.registerScreen,
      name: InitialRoutes.registerScreen,
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return RegisterScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.verifyNumber,
      name: InitialRoutes.verifyNumber,
      builder: (context, state) {
        final extra = state.extra as RegisterExtra;
        return VerifyNumberPage(
          ttl: extra.ttl,
          phoneNumber: extra.phoneNumber,
          action: extra.action ?? '',
        );
      },
    ),
    GoRoute(
      path: InitialRoutes.createPin,
      name: InitialRoutes.createPin,
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return CreatePinPage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.confirmPin,
      name: InitialRoutes.confirmPin,
      builder: (context, state) {
        // --- PERBAIKAN DI SINI ---
        // Kita sekarang mengharapkan extra berupa String, bukan Map.
        final phoneNumber = state.extra as String;
        return ConfirmPinPage(phoneNumber: phoneNumber);
      },
    ),
    // <<< BARU: Rute untuk alur Ubah Nomor Telepon >>>
    GoRoute(
      path: InitialRoutes.changePhone,
      name: InitialRoutes.changePhone,
      builder: (context, state) => const change_phone.ChangePhonePage(),
    ),
    GoRoute(
      path: InitialRoutes.confirmChangePhone,
      name: InitialRoutes.confirmChangePhone,
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return VerifyChangePhonePage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.pinLogin,
      name: InitialRoutes.pinLogin,
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return PinLoginPage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.personalData,
      name: InitialRoutes.personalData,
      builder: (context, state) => const PersonalDataPage(),
    ),

    GoRoute(
      path: InitialRoutes.resetPin,
      name: InitialRoutes.forgotPinNew,
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];

        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Token tidak valid atau hilang')),
          );
        }

        return FutureBuilder<String?>(
          future: SharedPreferences.getInstance().then(
            (prefs) => prefs.getString('last_forgot_pin_phone'),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final phoneNumber = snapshot.data;
            if (phoneNumber == null || phoneNumber.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text('Gagal mengambil data sesi. Silakan coba lagi.'),
                ),
              );
            }

            final extra = ForgotPinExtra(
              token: token,
              phoneNumber: phoneNumber,
            );
            return ForgotPinNewPage(extra: extra);
          },
        );
      },
    ),

    GoRoute(
      path: InitialRoutes.confirmPinForgot,
      name: InitialRoutes.confirmPinForgot,
      builder: (context, state) {
        final extra = state.extra as ForgotPinExtra;
        return ConfirmForgotPinPage(extra: extra);
      },
    ),

    GoRoute(
      path: InitialRoutes.newPin,
      name: InitialRoutes.newPin,
      builder: (context, state) => const ChangePinPage(),
    ),
    GoRoute(
      path: InitialRoutes.confirmNewPin,
      name: InitialRoutes.confirmNewPin,
      builder: (context, state) => const ConfirmChangePinPage(),
    ),
    GoRoute(
      path: InitialRoutes.verifyPinForChangePhone,
      name: InitialRoutes.verifyPinForChangePhone,
      builder: (context, state) => const VerifyPinForChangePhonePage(),
    ),
    GoRoute(
      path: InitialRoutes.verifyPinForChangePin,
      name: InitialRoutes.verifyPinForChangePin,
      builder: (context, state) => const VerifyPinForChangePinPage(),
    ),
    GoRoute(
      // Path harus cocok: '/banner-detail' + '/:bannerId'
      path: '${InitialRoutes.bannerDetail}/:bannerId',
      builder: (context, state) {
        // Ambil ID dari parameter URL
        final bannerId = state.pathParameters['bannerId']!;
        return BannerDetailPage(bannerId: bannerId);
      },
    ),
    GoRoute(
      path: InitialRoutes.myVouchers,
      name: InitialRoutes.myVouchers,
      builder: (context, state) => const MyVoucherPage(),
    ),
    GoRoute(
      path: InitialRoutes.myVoucherDetail,
      name: InitialRoutes.myVoucherDetail,
      builder: (context, state) {
        print('🔍 Debug: myVoucherDetail route called');
        print('🔍 Debug: path = ${InitialRoutes.myVoucherDetail}');
        print('🔍 Debug: state.extra = ${state.extra}');
        final claimedVoucher = state.extra as ClaimedVoucherEntity;
        print('🔍 Debug: claimedVoucher = ${claimedVoucher.voucher.code}');
        return profile_voucher_detail.VoucherDetailPage(
          claimedVoucher: claimedVoucher,
        );
      },
    ),
    GoRoute(
      path: InitialRoutes.pointHistory,
      name: InitialRoutes.pointHistory,
      builder: (context, state) => const PointHistoryPage(),
    ),
    GoRoute(
      path: InitialRoutes.orderDetail,
      name: InitialRoutes.orderDetail,
      builder: (context, state) {
        final orderId = state.extra as String;
        return OrderDetailPage(orderId: orderId);
      },
    ),

    // --- RUTE-RUTE DENGAN NAVBAR (DI DALAM SHELL) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BlocProvider.value(
          value: sl<AuthBloc>(),
          child: MainScreen(child: child),
        );
      },
      routes: [
        GoRoute(
          path: InitialRoutes.home,
          name: InitialRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: InitialRoutes.orders,
          name: InitialRoutes.orders,
          builder: (context, state) => const OrdersPage(),
          routes: [
            GoRoute(
              path: 'detail/:orderId',
              name: 'order-detail',
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return OrderDetailPage(orderId: orderId);
              },
            ),
          ],
        ),
        GoRoute(
          path: InitialRoutes.favorites,
          name: InitialRoutes.favorites,
          builder: (context, state) => const FavoritesPage(),
        ),
        GoRoute(
          path: InitialRoutes.vouchers,
          name: InitialRoutes.vouchers,
          builder: (context, state) => const VoucherPage(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              name: InitialRoutes.voucherDetail,
              builder: (context, state) {
                final voucherId = state.pathParameters['id'] ?? '';
                return VoucherDetailPage(voucherId: voucherId);
              },
            ),
          ],
        ),
        GoRoute(
          path: InitialRoutes.profile,
          name: InitialRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
