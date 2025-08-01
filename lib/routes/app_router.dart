import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/core/presentation/main_screen.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_extra.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/confirm_pin_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/create_pin_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/pin_login_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:nusantara_mobile/features/authentication/presentation/pages/verify_number.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/home_page.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_1.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_2.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_3.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/personal_data_page.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:nusantara_mobile/features/splash_screen/splash_screen.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

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
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return RegisterScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.verifyNumber,
      builder: (context, state) {
        final extra = state.extra as RegisterExtra;
        return VerifyNumberPage(ttl: extra.ttl, phoneNumber: extra.phoneNumber, action: extra.action ?? '');
      },
    ),
    GoRoute(
      path: InitialRoutes.createPin,
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return CreatePinPage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.confirmPin,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        final phoneNumber = args['phoneNumber'] as String;
        // final firstPin = args['firstPin'] as String; // Anda mungkin tidak butuh ini lagi
        return ConfirmPinPage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.pinLogin,
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return PinLoginPage(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: InitialRoutes.personalData,
      builder: (context, state) => const PersonalDataPage(),
    ),

    // =======================================================
    // PERHATIKAN: Rute /profile di bawah ini TELAH DIHAPUS
    // =======================================================
    // GoRoute(
    //   path: InitialRoutes.profile,
    //   builder: (context, state) => const ProfilePage(),
    // ),

    // --- RUTE-RUTE DENGAN NAVBAR (DI DALAM SHELL) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // AuthBloc harus disediakan di atas MaterialApp.router
        // agar bisa diakses oleh semua halaman di dalam shell
        return BlocProvider.value(
          value: sl<AuthBloc>(),
          child: MainScreen(child: child),
        );
      },
      routes: [
        GoRoute(
          path: InitialRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: InitialRoutes.orders,
          builder: (context, state) => const Center(child: Text('Halaman Pesanan')),
        ),
        GoRoute(
          path: InitialRoutes.favorites,
          builder: (context, state) => const Center(child: Text('Halaman Favorit')),
        ),
        GoRoute(
          path: InitialRoutes.vouchers,
          builder: (context, state) => const Center(child: Text('Halaman Voucher')),
        ),
        GoRoute(
          path: InitialRoutes.profile, // <-- DEFINISI /profile HANYA ADA DI SINI
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);