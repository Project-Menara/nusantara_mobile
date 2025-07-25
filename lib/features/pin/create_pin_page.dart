import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class CreatePinPage extends StatefulWidget {
  const CreatePinPage({super.key});

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  // Variabel untuk menyimpan PIN yang akan dibuat
  String _pin = '';
  final int _pinLength = 6;

  // Fungsi yang dipanggil saat tombol numpad ditekan
  void _onNumpadTapped(String value) {
    setState(() {
      if (_pin.length < _pinLength) {
        _pin += value;
      }
    });
  }

  // Fungsi untuk tombol hapus (backspace)
  void _onBackspaceTapped() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  // --- FUNGSI INI DIUBAH ---
  // Fungsi ini tidak lagi menyimpan, tapi pindah ke halaman konfirmasi
  void _goToConfirmPage() {
    // Menggunakan push untuk pindah ke halaman selanjutnya
    // dan mengirimkan `_pin` sebagai data 'extra'.
    context.push(InitialRoutes.confirmPin, extra: _pin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Create New PIN',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Konten Utama (Input & Tombol)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Create Your New PIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add a PIN number to make your account\nmore secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                  // Tampilan Indikator PIN
                  _buildPinDisplay(),
                  const SizedBox(height: 60),
                  // Tombol Buat PIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // --- PANGGIL FUNGSI YANG BARU ---
                      onPressed: _pin.length == _pinLength ? _goToConfirmPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        // Ganti teks tombol agar lebih sesuai
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          // Numpad Kustom
          _buildNumpad(),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan indikator PIN (angka dan titik)
  Widget _buildPinDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _pinLength; i++) {
      if (i < _pin.length) {
        displayWidgets.add(
          const Text(
            '●', // Tampilkan titik untuk keamanan
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        );
      } else {
        displayWidgets.add(
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayWidgets,
    );
  }

  /// Widget untuk membangun keypad numerik kustom
  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Colors.grey[200],
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
              const SizedBox(width: 90), // Placeholder agar '0' di tengah
              _buildNumpadButton('0'),
              _buildNumpadButton('', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membuat setiap tombol pada numpad
  Widget _buildNumpadButton(String number, {bool isBackspace = false}) {
    return SizedBox(
      width: 90,
      height: 60,
      child: Material(
        color: Colors.transparent, // Buat transparan agar efek InkWell terlihat
        child: InkWell(
          onTap: () {
            if (isBackspace) {
              _onBackspaceTapped();
            } else if (number.isNotEmpty) {
              _onNumpadTapped(number);
            }
          },
          borderRadius: BorderRadius.circular(8),
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