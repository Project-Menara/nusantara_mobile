import 'package:flutter/material.dart';

/// Keypad numerik custom yang didesain khusus untuk input nomor telepon,
/// untuk menghindari keyboard sistem dan masalah overflow.
class PhoneInputWidgets extends StatelessWidget {
  final ValueChanged<String> onNumpadTapped;
  final VoidCallback onBackspaceTapped;

  const PhoneInputWidgets({
    super.key,
    required this.onNumpadTapped,
    required this.onBackspaceTapped,
  });

  @override
  Widget build(BuildContext context) {
    return _buildNumpad();
  }

  /// Widget untuk membangun keypad numerik
  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 24.0, 0, 16.0),
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