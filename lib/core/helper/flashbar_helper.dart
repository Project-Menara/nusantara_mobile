import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

// Helper untuk menampilkan notifikasi dengan tampilan yang lebih elegan
void showAppFlashbar(
  BuildContext context, {
  required String title,
  required String message,
  bool isSuccess = true,
}) {
  context.showFlash<void>(
    // Durasi notifikasi tampil di layar
    duration: const Duration(seconds: 4),
    // Animasi saat notifikasi muncul dan menghilang
    transitionDuration: const Duration(milliseconds: 500),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        position: FlashPosition.top,
        behavior: FlashBehavior.floating,
        // --- BARU: Beri jarak dari tepi layar ---
        margin: const EdgeInsets.all(16.0),
        // --- BARU: Bentuk dengan bayangan (shadow) ---
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // --- BARU: Hapus border, ganti dengan shadow ---
        backgroundColor: Colors.white,
        // --- BARU: Garis indikator di sisi kiri ---
        indicatorColor: isSuccess ? Colors.green : Colors.red,
        icon: Icon(
          isSuccess ? Icons.check_circle_outline : Icons.error_outline,
          color: isSuccess ? Colors.green : Colors.red,
          size: 32,
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    },
  );
}
