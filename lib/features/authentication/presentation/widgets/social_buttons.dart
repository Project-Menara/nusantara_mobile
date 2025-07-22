import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahkan package flutter_svg

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Or continue with', style: TextStyle(color: Colors.black54)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Tombol Sosial Media
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton('assets/icons/google.svg'), // Sediakan ikon SVG
            const SizedBox(width: 20),
            _buildSocialButton('assets/icons/apple.svg'),
            const SizedBox(width: 20),
            _buildSocialButton('assets/icons/facebook.svg'),
          ],
        ),
        const SizedBox(height: 24),
        
        // Pindah ke Halaman Daftar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: () { /* Navigasi ke halaman Sign Up */ },
              child: Text(
                'Sign Up', // Typo "Sing In" diperbaiki menjadi "Sign Up"
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return InkWell(
      onTap: () { /* Aksi login sosial media */ },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            )
          ],
        ),
        child: SvgPicture.asset(
          assetPath,
          height: 24,
          width: 24,
        ),
      ),
    );
  }
}
