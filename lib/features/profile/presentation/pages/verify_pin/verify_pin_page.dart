import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/verify_pin/verify_pin_bloc.dart';

// Halaman ini bisa menerima argumen 'onSuccess' berupa callback function
// yang akan dieksekusi setelah PIN berhasil diverifikasi.
class VerifyPinPage extends StatelessWidget {
  final VoidCallback onSuccess;

  const VerifyPinPage({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyPinBloc>(),
      child: VerifyPinView(onSuccess: onSuccess),
    );
  }
}

class VerifyPinView extends StatefulWidget {
  final VoidCallback onSuccess;
  const VerifyPinView({super.key, required this.onSuccess});

  @override
  State<VerifyPinView> createState() => _VerifyPinViewState();
}

class _VerifyPinViewState extends State<VerifyPinView> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isPinVisible = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _onNumpadTapped(String value) {
    // Jangan izinkan input jika sedang loading
    if (context.read<VerifyPinBloc>().state is VerifyPinLoading) return;

    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        if (_pin.length == _pinLength) {
          _submitPin();
        }
      });
    }
  }

  void _onBackspaceTapped() {
    if (context.read<VerifyPinBloc>().state is VerifyPinLoading) return;
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _togglePinVisibility() {
    setState(() => _isPinVisible = !_isPinVisible);
  }

  // Mengirim event ke BLoC untuk verifikasi
  void _submitPin() {
    context.read<VerifyPinBloc>().add(VerifyPinSubmitted(pin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyPinBloc, VerifyPinState>(
      listener: (context, state) {
        if (state is VerifyPinSuccess) {
          // Jika sukses, tampilkan notifikasi dan panggil callback onSuccess
          showAppFlashbar(
            context,
            title: 'Berhasil',
            message: 'PIN Berhasil Diverifikasi!',
          );
          widget.onSuccess(); // Eksekusi aksi setelah sukses
        } else if (state is VerifyPinFailure) {
          // Jika gagal, tampilkan error dan reset input PIN
          showAppFlashbar(
            context,
            title: "Verifikasi Gagal",
            message: state.message,
            isSuccess: false,
          );
          setState(() => _pin = '');
        } 
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Verifikasi PIN Anda',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileLayout();
            } else {
              return _buildTabletLayout();
            }
          },
        ),
      ),
    );
  }

  /// Layout untuk layar sempit (Ponsel)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Masukkan PIN Keamanan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Untuk melanjutkan aksi ini, mohon masukkan 6-digit PIN Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  _buildPinInputSection(), // Widget untuk display PIN
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        PinInputWidgets(
          onNumpadTapped: _onNumpadTapped,
          onBackspaceTapped: _onBackspaceTapped,
        ),
      ],
    );
  }

  /// Layout untuk layar lebar (Tablet, Web, Ponsel Landscape)
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Panel Kiri: Informasi
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 80, color: Colors.orange.shade700),
                const SizedBox(height: 24),
                Text(
                  'Verifikasi Keamanan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Masukkan PIN Anda menggunakan keypad di sebelah kanan untuk mengonfirmasi aksi Anda.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel Kanan: Input PIN
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPinInputSection(),
                const SizedBox(height: 48),
                PinInputWidgets(
                  onNumpadTapped: _onNumpadTapped,
                  onBackspaceTapped: _onBackspaceTapped,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Widget bersama untuk menampilkan display PIN
  Widget _buildPinInputSection() {
    return BlocBuilder<VerifyPinBloc, VerifyPinState>(
      builder: (context, state) {
        // Jika sedang loading, tampilkan CircularProgressIndicator di tempat display PIN
        if (state is VerifyPinLoading) {
          return const SizedBox(
            height: 56, // Beri tinggi agar layout tidak "loncat"
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        // Tampilan display PIN default
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPinDisplay(),
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
        );
      },
    );
  }

  /// Widget untuk menampilkan bulatan-bulatan PIN
  Widget _buildPinDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _pinLength; i++) {
      displayWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 24,
            height: 32,
            child: Center(
              child: i < _pin.length
                  ? (_isPinVisible
                        ? Text(
                            _pin[i],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ))
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayWidgets,
    );
  }
}
