import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';

class CreatePinPage extends StatefulWidget {
  final String phoneNumber;
  const CreatePinPage({super.key, required this.phoneNumber});

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  String _pin = '';
  final int _pinLength = 6;
  // State baru untuk mengatur visibilitas PIN
  bool _isPinVisible = false;

  void _onNumpadTapped(String value) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += value);
    }
  }

  void _onBackspaceTapped() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  // Method baru untuk mengubah visibilitas PIN
  void _togglePinVisibility() {
    setState(() {
      _isPinVisible = !_isPinVisible;
    });
  }

  void _goToConfirmPage() {
    final args = {'phoneNumber': widget.phoneNumber, 'firstPin': _pin};
    context.push(InitialRoutes.confirmPin, extra: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text('Create Your New PIN', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Add a PIN number to make your account\nmore secure.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 60),
                  // Menggunakan Stack untuk menumpuk display PIN dan tombol visibility
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildPinDisplay(),
                      // Tombol untuk toggle visibility PIN
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            _isPinVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: _togglePinVisibility,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pin.length == _pinLength ? _goToConfirmPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Continue', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          PinInputWidgets(
            onNumpadTapped: _onNumpadTapped,
            onBackspaceTapped: _onBackspaceTapped,
          ),
        ],
      ),
    );
  }

  // Logika di dalam _buildPinDisplay diubah total
  Widget _buildPinDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _pinLength; i++) {
      displayWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          // Diberi SizedBox agar ukuran konsisten antara angka dan bulatan
          child: SizedBox(
            width: 24,
            height: 32, // Tinggi disesuaikan untuk angka
            child: Center(
              child: i < _pin.length
                  ? (_isPinVisible
                      // Tampilkan angka jika _isPinVisible true
                      ? Text(
                          _pin[i],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      // Tampilkan bulatan oranye jika false
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ))
                  // Tampilkan bulatan abu-abu untuk placeholder
                  : Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: displayWidgets);
  }
}