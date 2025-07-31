import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/onBoarding_screen/repositories/onBoarding_repository.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
                      onPressed: () async {
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
                      'assets/images/onboarding_box.png',
                      height: 250,
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      "Pengemasan Terbaik untuk Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Setiap pesanan Anda kami kemas dengan cermat agar tetap terjaga kualitasnya selama pengiriman.",
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
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DotIndicator(isActive: false),
                        SizedBox(width: 8),
                        DotIndicator(isActive: true),
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
                            context.push(InitialRoutes.onboarding3);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Anda mungkin perlu menambahkan widget DotIndicator di sini jika belum ada
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
