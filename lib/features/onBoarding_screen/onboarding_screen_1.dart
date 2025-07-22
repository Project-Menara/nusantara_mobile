import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Column(
                children: [
                  Image.asset(
                    'assets/images/onboarding_tote_bag.png',
                    height: 250,
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    "Oleh-Oleh untuk Kenangan Manis Anda",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Hadir dengan ragam produk oleh-oleh khas Medan yang berkualitas. Kami berkomitmen menyajikan keaslian dan cita rasa terbaik untuk Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DotIndicator(isActive: true),
                      SizedBox(width: 8),
                      DotIndicator(isActive: false),
                      SizedBox(width: 8),
                      DotIndicator(isActive: false),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // PERBAIKAN: Gunakan context.push() agar bisa kembali
                          context.push(InitialRoutes.onboarding2);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
