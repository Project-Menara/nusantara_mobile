import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

// Helper untuk menampilkan notifikasi clean & modern tanpa ikon
void showAppFlashbar(
  BuildContext context, {
  required String title,
  required String message,
  bool isSuccess = true,
}) {
  context.showFlash<void>(
    duration: const Duration(seconds: 4),
    transitionDuration: const Duration(milliseconds: 400),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        position: FlashPosition.top,
        behavior: FlashBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isSuccess
            ? Colors.green.shade50
            : Colors.red.shade50, // warna lembut
        indicatorColor: isSuccess ? Colors.green : Colors.red,
        shadowColor: Colors.black.withOpacity(0.05),
        elevation: 8,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isSuccess
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    },
  );
}
