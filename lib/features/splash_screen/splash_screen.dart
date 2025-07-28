import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ganti dengan path impor BLoC dan Rute Anda
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
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
    context.read<AuthBloc>().add(AuthCheckStatusRequested());
  }

  Future<void> _checkOnboardingStatusAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted =
        prefs.getBool('onboarding_completed') ?? false;

    // Pastikan widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    if (onboardingCompleted) {
      context.go(InitialRoutes.loginScreen);
    } else {
      context.go(InitialRoutes.onboarding1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        Future.delayed(const Duration(seconds: 2), () {
          if (state is AuthLoginSuccess) {
            context.go(InitialRoutes.home);
          } else if (state is AuthUnauthenticated) {
            _checkOnboardingStatusAndNavigate();
          }
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
