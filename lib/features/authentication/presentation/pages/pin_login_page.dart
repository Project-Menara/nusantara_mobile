// pin_login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

// Wrapper untuk menyediakan BLoC
class PinLoginPage extends StatelessWidget {
  final String phoneNumber;
  const PinLoginPage({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: PinLoginView(phoneNumber: phoneNumber),
    );
  }
}

// Widget untuk UI dan State
class PinLoginView extends StatefulWidget {
  final String phoneNumber;
  const PinLoginView({super.key, required this.phoneNumber});

  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isPinVisible = false;

  @override
  void initState() {
    super.initState();
    // Jika Anda ingin menampilkan info user, bisa panggil event di sini
  }

  // Method ini diubah untuk otomatis submit
  void _onNumpadTapped(String value) {
    // Jangan izinkan input jika sedang loading
    if (context.read<AuthBloc>().state is AuthLoading) return;

    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        // Jika PIN sudah lengkap, langsung trigger proses login
        if (_pin.length == _pinLength) {
          _submitLogin();
        }
      });
    }
  }

  void _onBackspaceTapped() {
    if (context.read<AuthBloc>().state is AuthLoading) return;

    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _togglePinVisibility() {
    setState(() {
      _isPinVisible = !_isPinVisible;
    });
  }

  void _submitLogin() {
    context.read<AuthBloc>().add(
      AuthLoginWithPinSubmitted(phoneNumber: widget.phoneNumber, pin: _pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          // Jika login sukses, navigasi ke halaman utama
          context.go(InitialRoutes.home);
        } else if (state is AuthLoginFailure) {
          // Jika gagal, tampilkan pesan error dan reset PIN
          showAppFlashbar(
            context,
            title: "Login Gagal",
            message: state.message,
            isSuccess: false,
          );
          setState(() {
            _pin = '';
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Masukkan PIN',
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
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const Spacer(),
                    // Anda bisa menambahkan info user di sini jika perlu
                    const Text(
                      'Selamat Datang Kembali!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan 6-digit PIN Anda untuk melanjutkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 60),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Tampilkan indikator loading atau display PIN
                            state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.orange,
                                  )
                                : _buildPinDisplay(),
                            // Tombol visibility tetap ada
                            if (state is! AuthLoading)
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    _isPinVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _togglePinVisibility,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const Spacer(flex: 2),
                    // Tidak ada tombol "Continue" di sini
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
      ),
    );
  }

  Widget _buildPinDisplay() {
    // Logika display PIN sama seperti sebelumnya
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
