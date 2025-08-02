import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/repositories/onBoarding_repository.dart';

// Ganti dengan path impor BLoC dan Rute Anda
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // <<< PERBAIKAN: Hapus pemanggilan event dari sini >>>
    // Event ini sudah dipanggil di main.dart saat aplikasi pertama kali dibuat.
    // context.read<AuthBloc>().add(AuthCheckStatusRequested());
  }

  Future<void> _checkOnboardingStatusAndNavigate() async {
    // Pastikan widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    final onBoarRepo = OnboardingRepository();
    final hasSeenOnboard = await onBoarRepo.hasSeenOnBoarding;

    if (!mounted) return;

    if (!hasSeenOnboard) {
      context.go(InitialRoutes.onboarding1);
    } else {
      context.go(InitialRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Tunda navigasi untuk memberi waktu splash screen terlihat
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          // <<< PERBAIKAN: Cek AuthGetUserSuccess juga sebagai kondisi sukses >>>
          if (state is AuthLoginSuccess || state is AuthGetUserSuccess) {
            context.go(InitialRoutes.home);
          } else if (state is AuthUnauthenticated) {
            _checkOnboardingStatusAndNavigate();
          }
          // Jika state masih loading atau initial, listener tidak akan melakukan apa-apa,
          // membiarkan splash screen tetap tampil.
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png', // Sesuaikan dengan path logo Anda
                width: 200,
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.orange, // Sesuaikan warna
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}