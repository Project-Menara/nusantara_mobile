// flashbar_helper.dart

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

// Helper untuk menampilkan notifikasi
void showAppFlashbar(
  BuildContext context, {
  required String title,
  required String message,
  bool isSuccess = true,
}) {
  context.showFlash<void>(
    barrierColor: Colors.black54,
    barrierDismissible: true,
    // --- DURATION & ANIMASI DIPINDAHKAN KE SINI ---
    duration: const Duration(seconds: 4),
    // --- ------------------------------------ ---
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        position: FlashPosition.top,
        behavior: FlashBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
            width: 1.5,
          ),
        ),
        backgroundColor:
            isSuccess ? Colors.green.shade100 : Colors.red.shade100,
        // 'duration' dan 'forwardAnimationCurve' DIHAPUS DARI SINI
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                      isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ],
          ),
        ),
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
          size: 32,
        ),
      );
    },
  );
}