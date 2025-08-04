import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

//===========================================================================
// WIDGET & HELPER GENERIC (Bisa untuk konfirmasi apapun)
//===========================================================================

/// Menampilkan dialog konfirmasi kustom yang generic.
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'Ya',
  Color confirmButtonColor = Colors.red,
  IconData icon = Icons.warning_amber_rounded,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        confirmButtonColor: confirmButtonColor,
        icon: icon,
      );
    },
  );
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.confirmButtonColor,
    required this.icon,
  });

  final String title;
  final String content;
  final String confirmText;
  final Color confirmButtonColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: confirmButtonColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmButtonColor, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//===========================================================================
// HELPER SPESIFIK UNTUK UBAH PIN
//===========================================================================

/// Menampilkan dialog konfirmasi khusus untuk ubah PIN.
Future<void> showChangePinConfirmationDialog(BuildContext context) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    title: 'Ubah PIN Keamanan',
    content:
        'Anda akan diarahkan ke halaman untuk membuat PIN baru. Lanjutkan?',
    confirmText: 'Lanjutkan',
    confirmButtonColor: Colors.orange.shade700,
    icon: Icons.lock_reset_rounded,
  );

  if (confirmed == true && context.mounted) {
    context.push(InitialRoutes.newPin);
  }
}
