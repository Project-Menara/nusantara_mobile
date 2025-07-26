import 'package:flutter/material.dart';

class OtpInputWidgets extends StatelessWidget {
  final String
  otpCode; // Properti ini tidak lagi digunakan, tapi biarkan untuk sementara
  final int otpLength; // Properti ini tidak lagi digunakan
  final ValueChanged<String> onNumpadTapped;
  final VoidCallback onBackspaceTapped;

  const OtpInputWidgets({
    super.key,
    required this.otpCode,
    required this.onNumpadTapped,
    required this.onBackspaceTapped,
    this.otpLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    // Langsung kembalikan numpad, tanpa Column atau kotak display lagi.
    return _buildNumpad();
  }

  // Method _buildPinDisplay() TELAH DIHAPUS karena sudah tidak diperlukan lagi.
  // Tampilan OTP kini sepenuhnya diatur oleh VerifyNumberView.

  /// Widget untuk membangun keypad numerik
  Widget _buildNumpad() {
    // Tidak ada perubahan pada method ini
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 24.0, 0, 16.0), // Sesuaikan padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('1'),
              _buildNumpadButton('2'),
              _buildNumpadButton('3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('4'),
              _buildNumpadButton('5'),
              _buildNumpadButton('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('7'),
              _buildNumpadButton('8'),
              _buildNumpadButton('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 90), // Placeholder
              _buildNumpadButton('0'),
              _buildNumpadButton('', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk setiap tombol pada numpad
  Widget _buildNumpadButton(String number, {bool isBackspace = false}) {
    // Tidak ada perubahan pada method ini
    return SizedBox(
      width: 90,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isBackspace) {
              onBackspaceTapped();
            } else {
              onNumpadTapped(number);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isBackspace
                ? const Icon(Icons.backspace_outlined, color: Colors.black54)
                : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
