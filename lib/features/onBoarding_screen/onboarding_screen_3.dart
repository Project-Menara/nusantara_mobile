import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/onboarding_screen_1.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/repositories/onBoarding_repository.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        // PERBAIKAN: Gunakan context.pop() untuk kembali
                        context.pop();
                      },
                    ),
                    TextButton(
                      onPressed: () async{
                          final onBoardRepo = OnboardingRepository();
                          await onBoardRepo.setSession();                        
                          context.go(InitialRoutes.loginScreen);
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // ... sisa kode konten tidak berubah ...
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/onboarding_cart.png',
                      height: 250,
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      "Mulai Belanja Sekarang!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Jelajahi koleksi lengkap kami dan temukan oleh-oleh yang sempurna. Proses pemesanan yang cepat dan aman.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DotIndicator(isActive: false),
                        SizedBox(width: 8),
                        DotIndicator(isActive: false),
                        SizedBox(width: 8),
                        DotIndicator(isActive: true),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final onBoardRepo = OnboardingRepository();
                          await onBoardRepo.setSession();
                          // PERBAIKAN: Gunakan context.go() untuk ke login
                          context.go(InitialRoutes.loginScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Started",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
