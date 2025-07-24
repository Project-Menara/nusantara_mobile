import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyNumberPage extends StatefulWidget {
  const VerifyNumberPage({super.key, required String phoneNumber});

  @override
  State<VerifyNumberPage> createState() => _VerifyNumberPageState();
}

class _VerifyNumberPageState extends State<VerifyNumberPage> {
  // Variabel untuk menyimpan PIN yang dimasukkan
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Cek dulu apakah bisa kembali atau tidak
            if (context.canPop()) {
              // Jika bisa, maka kembali
              context.pop();
            } else {
              // Jika tidak, arahkan ke halaman login/home
              context.go('/login'); // Sesuaikan rute Anda
            }
          },
        ),
        title: const Text(
          'Verify Number',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16, // ⬅️ Tambahkan atau ubah ini
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Verify Your Number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    // 'Input 6 Digits PIN Number to logging in to\nNusantara Oleh Oleh',
                    'Enter your OTP code below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                  // Tampilan Indikator PIN (Angka dan Titik)
                  _buildPinDisplay(),
                  const SizedBox(height: 60),
                  // Tombol Next
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pin.length == _pinLength
                          ? () {
                              print('PIN yang dimasukkan: $_pin');
                            }
                          : null,
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
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lupa PIN
                  TextButton(
                    onPressed: () {},
                    child: RichText(
                      text: TextSpan(
                        text: 'Forgot your PIN ? ',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Reset PIN',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          // Numpad Kustom Sesuai Desain
          _buildNumpad(),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan indikator PIN (angka atau titik)
  /// Widget untuk menampilkan indikator PIN (angka atau titik)
  Widget _buildPinDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _pinLength; i++) {
      // Widget yang akan ditambahkan ke list
      Widget pinWidget;

      if (i < _pin.length) {
        // Buat widget Text untuk angka yang sudah diinput
        final numberText = Text(
          _pin[i],
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        );

        // Cek apakah ini adalah digit TERAKHIR yang dimasukkan
        if (i == _pin.length - 1) {
          // Jika ya, bungkus dengan GestureDetector agar bisa diketuk untuk menghapus
          pinWidget = GestureDetector(
            onTap: _onBackspaceTapped, // Panggil fungsi hapus saat diketuk
            child: numberText,
          );
        } else {
          // Jika bukan digit terakhir, tampilkan seperti biasa
          pinWidget = numberText;
        }
      } else {
        // Tampilkan titik besar jika belum diinput
        pinWidget = const Text(
          '●',
          style: TextStyle(fontSize: 32, color: Colors.black),
        );
      }
      displayWidgets.add(pinWidget);
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
              _buildNumpadButton('1', ''),
              _buildNumpadButton('2', 'ABC'),
              _buildNumpadButton('3', 'DEF'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('4', 'GHI'),
              _buildNumpadButton('5', 'JKL'),
              _buildNumpadButton('6', 'MNO'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('7', 'PQRS'),
              _buildNumpadButton('8', 'TUV'),
              _buildNumpadButton('9', 'WXYZ'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 90), // Placeholder agar '0' di tengah
              _buildNumpadButton('0', ''),
              _buildNumpadButton('', '', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membuat setiap tombol pada numpad
  Widget _buildNumpadButton(
    String number,
    String letters, {
    bool isBackspace = false,
  }) {
    return SizedBox(
      width: 90,
      height: 60,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (letters.isNotEmpty)
                        Text(
                          letters,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
