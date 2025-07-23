import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // WARNA UTAMA BARU: Disesuaikan agar sama persis dengan Figma.
  static const Color primaryOrange = Color(0xFFF57C00); // Oranye yang lebih cerah

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryOrange, // Background utama diset ke warna oranye
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildLoginForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: primaryOrange,
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 50),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 40), // Ukuran logo disesuaikan
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // Jarak di header disesuaikan
            const Text(
              "Oleh-oleh khas Indonesia kini lebih dekat",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22, // Ukuran font disesuaikan
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12), // Jarak di header disesuaikan
            const Text(
              "Dapatkan akses promo eksklusif dan hadiah serta menu favorit Anda",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Ukuran font disesuaikan
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)), // Radius diperbesar
      ),
      // Transform diperbesar untuk efek overlap yang lebih dramatis
      transform: Matrix4.translationValues(0, -30, 0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "MASUKKAN NOMOR TELEPON ANDA",
              style: TextStyle(
                  fontSize: 15, // Ukuran font disesuaikan
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "Anda dapat masuk atau membuat akun baru di Aplikasi Nusantara Oleh Oleh",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              "Nomor Telepon",
              // FontWeight dihilangkan agar sesuai desain (tidak tebal)
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Masukkan nomor telepon",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: primaryOrange, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push(InitialRoutes.verifyPin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange, // Menggunakan warna utama baru
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                shadowColor: primaryOrange.withOpacity(0.5),
              ),
              child: const Text(
                "Lanjutkan",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  context.go(InitialRoutes.home);
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryOrange, // Menggunakan warna utama baru
                ),
                child: const Text(
                  "Lanjut sebagai Tamu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryOrange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}