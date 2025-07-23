import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyPinPage extends StatefulWidget {
  const VerifyPinPage({super.key});

  @override
  State<VerifyPinPage> createState() => _VerifyPinPageState();
}

class _VerifyPinPageState extends State<VerifyPinPage> {
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
          'Verify PIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Konten Utama (Input & Tombol)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'INPUT PIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Input 6 Digits PIN Number to logging in to\nNusantara Oleh Oleh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Tampilan Indikator PIN (Angka dan Titik)
                  _buildPinDisplay(),
                  const SizedBox(height: 48),
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

// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart'; // Impor package pinput

// class VerifyPinPage extends StatefulWidget {
//   const VerifyPinPage({super.key});

//   @override
//   State<VerifyPinPage> createState() => _VerifyPinPageState();
// }

// class _VerifyPinPageState extends State<VerifyPinPage> {
//   // Gunakan TextEditingController untuk mengelola input dari pinput
//   final pinController = TextEditingController();
//   final focusNode = FocusNode();

//   // Variabel untuk mengontrol status tombol Next
//   bool isPinComplete = false;

//   @override
//   void dispose() {
//     // Selalu dispose controller saat widget tidak lagi digunakan
//     pinController.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Definisikan tema untuk kotak PIN
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 60,
//       textStyle: const TextStyle(
//         fontSize: 22,
//         fontWeight: FontWeight.bold,
//         color: Colors.black,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade400),
//       ),
//     );

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Verify PIN',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'INPUT PIN',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Input 6 Digits PIN Number to logging in to\nNusantara Oleh Oleh',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 48),

//                 // GANTI TAMPILAN PIN DENGAN WIDGET PINPUT
//                 Pinput(
//                   length: 6,
//                   controller: pinController,
//                   focusNode: focusNode,
//                   keyboardType: TextInputType.number,
//                   defaultPinTheme: defaultPinTheme,
//                   focusedPinTheme: defaultPinTheme.copyWith(
//                     decoration: defaultPinTheme.decoration!.copyWith(
//                       border: Border.all(color: Colors.orange),
//                     ),
//                   ),
//                   submittedPinTheme: defaultPinTheme.copyWith(
//                      decoration: defaultPinTheme.decoration!.copyWith(
//                       border: Border.all(color: Colors.green),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       isPinComplete = value.length == 6;
//                     });
//                   },
//                   onCompleted: (pin) {
//                     // Otomatis trigger aksi saat pin selesai diisi
//                     print('PIN selesai diisi: $pin');
//                   },
//                 ),

//                 const SizedBox(height: 48),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: isPinComplete
//                         ? () {
//                             // Logika verifikasi PIN
//                             print('PIN yang dimasukkan: ${pinController.text}');
//                           }
//                         : null, // Tombol nonaktif jika PIN belum 6 digit
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       disabledBackgroundColor: Colors.orange.withOpacity(0.5),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Next',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 TextButton(
//                   onPressed: () {
//                     // Logika untuk reset PIN
//                   },
//                   child: RichText(
//                     text: const TextSpan(
//                       text: 'Forgot your PIN ? ',
//                       style: TextStyle(color: Colors.black54, fontSize: 14),
//                       children: <TextSpan>[
//                         TextSpan(
//                           text: 'Reset PIN',
//                           style: TextStyle(
//                             color: Colors.orange,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Spacer(), // Mendorong konten ke tengah jika keyboard tidak muncul
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
