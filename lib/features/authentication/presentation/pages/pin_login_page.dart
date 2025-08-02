import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< TAMBAHKAN IMPORT INI

// Wrapper untuk menyediakan BLoC
class PinLoginPage extends StatelessWidget {
  final String phoneNumber;
  const PinLoginPage({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    // Gunakan BlocProvider.value karena AuthBloc adalah Singleton
    return BlocProvider.value(
      value: sl<AuthBloc>(),
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

  Timer? _timer;
  int _countdownSeconds = 0;
  bool get _isRateLimited => _timer?.isActive ?? false;

  bool _isForgotPinLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() {
      _countdownSeconds = seconds;
      _pin = '';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        setState(() {});
      }
    });
  }

  void _onNumpadTapped(String value) {
    if (context.read<AuthBloc>().state is AuthLoginLoading || _isRateLimited) return;
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        if (_pin.length == _pinLength) {
          _submitLogin();
        }
      });
    }
  }

  void _onBackspaceTapped() {
    if (context.read<AuthBloc>().state is AuthLoginLoading || _isRateLimited) return;
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _togglePinVisibility() {
    setState(() => _isPinVisible = !_isPinVisible);
  }

  void _submitLogin() {
    context.read<AuthBloc>().add(
          AuthLoginWithPinSubmitted(phoneNumber: widget.phoneNumber, pin: _pin),
        );
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  void _forgotPin() async { // 1. Ubah menjadi async
    try {
      // 2. Simpan nomor telepon ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_forgot_pin_phone', widget.phoneNumber);
      
      // 3. Kirim event ke BLoC (pastikan widget masih ada/mounted)
      if (mounted) {
        context.read<AuthBloc>().add(AuthForgotPinRequested(widget.phoneNumber));
      }
    } catch (e) {
      // Menangani jika ada error saat menyimpan ke SharedPreferences
      if(mounted) {
        showAppFlashbar(context, title: "Error Lokal", message: "Gagal menyimpan sesi sementara.", isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Atur state loading untuk tombol lupa pin
        if (state is AuthForgotPinLoading) {
          setState(() => _isForgotPinLoading = true);
        }
        // Hentikan loading lupa pin jika sudah selesai (baik sukses maupun gagal)
        if (state is AuthForgotPinSuccess || state is AuthFailure) {
          setState(() => _isForgotPinLoading = false);
        }

        if (state is AuthLoginSuccess) {
          context.go(InitialRoutes.home);
        } else if (state is AuthLoginRateLimited) {
          showAppFlashbar(context, title: "Terlalu Banyak Percobaan", message: state.message, isSuccess: false);
          _startCountdown(state.retryAfterSeconds);
        } else if (state is AuthLoginFailure) {
          showAppFlashbar(context, title: "Login Gagal", message: state.message, isSuccess: false);
          setState(() => _pin = '');
        } else if (state is AuthForgotPinSuccess) {
          showAppFlashbar(
            context,
            title: "Permintaan Terkirim",
            message: "Link untuk mengatur ulang PIN telah dikirim melalui WhatsApp.",
            isSuccess: true,
          );
        } else if (state is AuthFailure) {
          showAppFlashbar(
            context,
            title: "Terjadi Kesalahan",
            message: state.message,
            isSuccess: false,
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          context.go(InitialRoutes.loginScreen);
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Masukkan PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go(InitialRoutes.loginScreen),
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
                      const Text('Selamat Datang Kembali!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Masukkan 6-digit PIN Anda untuk melanjutkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 60),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (_isRateLimited) {
                            return Text('Coba lagi dalam $_countdownSeconds detik', style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold));
                          }
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              if (state is AuthLoginLoading)
                                const CircularProgressIndicator(color: Colors.orange)
                              else
                                _buildPinDisplay(),
                              if (state is! AuthLoginLoading)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(_isPinVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                    onPressed: _togglePinVisibility,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      _buildForgotPasswordButton(),
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
        ),
      ),
    );
  }
  
  Widget _buildForgotPasswordButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: _isForgotPinLoading
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : TextButton(
              onPressed: _forgotPin,
              child: const Text(
                'Lupa PIN?',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

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
                      ? Text(_pin[i], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black))
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        ))
                  : Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
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