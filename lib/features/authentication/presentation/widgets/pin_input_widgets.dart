import 'package:flutter/material.dart';

class PinInputWidgets extends StatelessWidget {
  // Properti 'pin' dan 'pinLength' sudah tidak diperlukan lagi di sini
  final ValueChanged<String> onNumpadTapped;
  final VoidCallback onBackspaceTapped;

  const PinInputWidgets({
    super.key,
    required this.onNumpadTapped,
    required this.onBackspaceTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Widget ini sekarang hanya mengembalikan numpad
    return _buildNumpad();
  }

  /// Widget untuk membangun keypad numerik kustom.
  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      // Ubah warna latar belakang agar menyatu dengan halaman utama
      color: Colors.white, 
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['1', '2', '3'].map((e) => _buildNumpadButton(e)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['4', '5', '6'].map((e) => _buildNumpadButton(e)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['7', '8', '9'].map((e) => _buildNumpadButton(e)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 90, height: 60), // Placeholder
              _buildNumpadButton('0'),
              _buildNumpadButton('', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk setiap tombol numpad.
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
                : Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),
      ),
    );
  }
}