import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmPinPage extends StatefulWidget {
  // Menerima PIN pertama dari halaman sebelumnya
  final String firstPin;

  const ConfirmPinPage({super.key, required this.firstPin});

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  String _pin = '';
  final int _pinLength = 6;

  void _onNumpadTapped(String value) {
    setState(() {
      if (_pin.length < _pinLength) {
        _pin += value;
      }
    });
  }

  void _onBackspaceTapped() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  // Fungsi untuk memvalidasi dan menyimpan PIN
  void _confirmAndSavePin() {
    if (_pin == widget.firstPin) {
      // --- PIN COCOK ---
      // Di sini Anda akan memanggil API untuk menyimpan PIN
      print('PIN cocok dan berhasil disimpan: $_pin');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN baru berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
      // Arahkan ke halaman utama setelah berhasil
      context.go('/home');
    } else {
      // --- PIN TIDAK COCOK ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN tidak cocok. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
      // Kosongkan input PIN agar pengguna bisa mengulang
      setState(() {
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Confirm Your PIN',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Confirm Your PIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Re-enter your PIN to confirm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                  _buildPinDisplay(),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pin.length == _pinLength
                          ? _confirmAndSavePin
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
                        'Confirm & Save',
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
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildPinDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _pinLength; i++) {
      if (i < _pin.length) {
        displayWidgets.add(
          const Text(
            '●',
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

  Widget _buildNumpad() {
    // Numpad sama persis dengan halaman sebelumnya, jadi bisa di-copy paste
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
              const SizedBox(width: 90),
              _buildNumpadButton('0'),
              _buildNumpadButton('', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String number, {bool isBackspace = false}) {
    return SizedBox(
      width: 90,
      height: 60,
      child: Material(
        color: Colors.transparent,
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
