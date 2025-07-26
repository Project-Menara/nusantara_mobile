// login_header_widget.dart

import 'package:flutter/material.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Hapus warna agar background oranye dari parent (Scaffold) terlihat
      color: Colors.transparent, 
      // Padding bawah dikurangi agar tidak ada jarak kosong yang besar
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 40), 
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const SizedBox(height: 24),
            const Text(
              "Oleh-oleh khas Indonesia kini lebih dekat",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 12),
            const Text(
              "Dapatkan akses promo eksklusif dan hadiah serta menu favorit Anda",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}