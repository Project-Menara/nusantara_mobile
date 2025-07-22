import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- 1. Impor GoRouter
import 'package:nusantara_mobile/routes/initial_routes.dart'; // <-- 2. Impor Rute Anda

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Bagian Atas (Header Oranye) ---
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png', height: 100),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(Icons.keyboard_arrow_down, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text("Oleh-oleh khas Indonesia kini lebih dekat", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("Dapatkan akses promo eksklusif dan hadiah serta menu favorit Anda", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // --- Bagian Bawah (Form Putih) ---
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("MASUKKAN NOMOR TELEPON ANDA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Anda dapat masuk atau membuat akun baru di Aplikasi Nusantara Oleh Oleh", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 24),
                    const Text("Nomor Telepon", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Masukkan nomor telepon",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // PERBAIKAN DI SINI: Navigasi ke HomePage
                        context.go(InitialRoutes.home);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Lanjutkan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Logika untuk lanjut sebagai tamu juga bisa ke home
                          context.go(InitialRoutes.home);
                        },
                        child: const Text("Lanjut sebagai Tamu", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.orange)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}