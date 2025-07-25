// lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/core/presentation/main_screen.dart';
// Perbaiki path import jika nama file sebenarnya adalah 'register_page.dart'
import 'package:nusantara_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:nusantara_mobile/features/pin/confirm_pin_page.dart';
import 'package:nusantara_mobile/features/pin/create_pin_page.dart';
// Perbaiki path import jika nama file sebenarnya adalah 'verify_pin_page.dart'
import 'package:nusantara_mobile/features/pin/verify_number.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

// Impor semua halaman yang Anda butuhkan
import 'package:nusantara_mobile/features/splash_screen/splash_screen.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_1.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_2.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_3.dart';
// Perbaiki path import jika nama file sebenarnya adalah 'login_page.dart'
import 'package:nusantara_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/home_page.dart';

// Kunci navigator untuk ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRoute = GoRouter(
  initialLocation: InitialRoutes.splashScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    // --- RUTE DI LUAR CANGKANG (SHELL) ---
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

    // ========================================================
    // == PERBAIKANNYA ADA DI SINI ==
    // ========================================================
    GoRoute(
      path: InitialRoutes.registerScreen,
      builder: (context, state) {
        // 1. Ambil data yang dikirim dari LoginScreen melalui 'extra'
        final phoneNumber = state.extra as String? ?? '';

        // 2. Masukkan data tersebut ke dalam RegisterScreen
        return RegisterScreen(phoneNumber: phoneNumber);
      },
    ),

    // ========================================================
    GoRoute(
      path: InitialRoutes.verifyNumber,
      builder: (context, state) {
        // Lakukan hal yang sama untuk VerifyPin jika perlu mengirim nomor telepon
        final phoneNumber = state.extra as String? ?? '';
        return VerifyNumberPage(
          phoneNumber: phoneNumber,
        ); // Asumsi VerifyPinPage menerima phoneNumber
      },
    ),
    GoRoute(
      path: InitialRoutes.createPin,
      builder: (context, state) {
        // Ambil data yang dikirim dari VerifyNumberPage melalui 'extra'
        final phoneNumber = state.extra as String? ?? '';
        return const CreatePinPage(); // Asumsi CreatePinPage menerima phoneNumber
      },
    ),
    GoRoute(
      path: InitialRoutes.confirmPin,
      builder: (context, state) {
        // Ambil data yang dikirim dari CreatePinPage melalui 'extra'
        final phoneNumber = state.extra as String? ?? '';
        return ConfirmPinPage(firstPin: '');
      },
    ),
    // --- RUTE DI DALAM CANGKANG (SHELL) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BlocProvider(
          create: (context) => sl<HomeBloc>(),
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
          builder: (context, state) =>
              const Center(child: Text('Halaman Pesanan')),
        ),
        GoRoute(
          path: InitialRoutes.favorites,
          builder: (context, state) =>
              const Center(child: Text('Halaman Favorit')),
        ),
        GoRoute(
          path: InitialRoutes.vouchers,
          builder: (context, state) =>
              const Center(child: Text('Halaman Voucher')),
        ),
        GoRoute(
          path: InitialRoutes.profile,
          builder: (context, state) =>
              const Center(child: Text('Halaman Profil')),
        ),
      ],
    ),
  ],
);
