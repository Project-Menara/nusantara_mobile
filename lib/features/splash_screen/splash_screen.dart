import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- 1. Impor GoRouter
import 'package:nusantara_mobile/routes/initial_routes.dart'; // <-- 2. Impor Rute Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // HAPUS PERINTAH LAMA INI:
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
      // );

      // PERBAIKAN: Gunakan context.go() untuk navigasi pertama
      if (mounted) { // Pastikan widget masih ada di tree
        context.go(InitialRoutes.onboarding1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Sesuaikan dengan path logo Anda
          width: 200,
        ),
      ),
    );
  }
}