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
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginPage extends StatelessWidget {
  final String phoneNumber;
  const PinLoginPage({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: PinLoginView(phoneNumber: phoneNumber),
    );
  }
}

class PinLoginView extends StatefulWidget {
  final String phoneNumber;
  const PinLoginView({super.key, required this.phoneNumber});

  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  // --- State Management ---
  String _pin = '';
  final int _pinLength = 6;
  bool _isPinVisible = false;

  Timer? _rateLimitTimer;
  int _rateLimitCountdownSeconds = 0;
  bool get _isRateLimited => _rateLimitTimer?.isActive ?? false;

  Timer? _forgotPinTimer;
  int _forgotPinCountdownSeconds = 0;
  bool get _isForgotPinOnCooldown => _forgotPinTimer?.isActive ?? false;

  // <<< BARU: Kunci untuk SharedPreferences >>>
  static const String _rateLimitExpiryKey = 'rate_limit_expiry_timestamp';

  @override
  void initState() {
    super.initState();
    // <<< PERBAIKAN: Periksa rate limit yang aktif saat halaman dibuka >>>
    _checkActiveRateLimit();
  }

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    _forgotPinTimer?.cancel();
    super.dispose();
  }

  // --- Functions ---

  // <<< BARU: Fungsi untuk memeriksa SharedPreferences >>>
  void _checkActiveRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_rateLimitExpiryKey);

    if (expiryTimestamp != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (expiryTime.isAfter(DateTime.now())) {
        final remainingSeconds = expiryTime.difference(DateTime.now()).inSeconds;
        if (remainingSeconds > 0) {
          _startRateLimitCountdown(remainingSeconds);
        }
      } else {
        // Hapus jika sudah kedaluwarsa
        await prefs.remove(_rateLimitExpiryKey);
      }
    }
  }

  void _startRateLimitCountdown(int seconds) async {
    _rateLimitTimer?.cancel();
    setState(() {
      _rateLimitCountdownSeconds = seconds;
      _pin = '';
    });

    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_rateLimitCountdownSeconds > 0) {
        setState(() => _rateLimitCountdownSeconds--);
      } else {
        timer.cancel();
        // <<< PERBAIKAN: Hapus key dari SharedPreferences saat timer selesai >>>
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_rateLimitExpiryKey);
        setState(() {});
      }
    });
  }
  
  void _startForgotPinCooldown() {
    _forgotPinTimer?.cancel();
    setState(() => _forgotPinCountdownSeconds = 120);
    _forgotPinTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_forgotPinCountdownSeconds > 0) {
        setState(() => _forgotPinCountdownSeconds--);
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

  void _forgotPin() async {
    _startForgotPinCooldown();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_forgot_pin_phone', widget.phoneNumber);
    if (mounted) {
      context.read<AuthBloc>().add(AuthForgotPinRequested(widget.phoneNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async { // Jadikan async
        if (state is AuthLoginSuccess) {
          context.go(InitialRoutes.home);
        } else if (state is AuthLoginRateLimited) {
          showAppFlashbar(context, title: "Terlalu Banyak Percobaan", message: state.message, isSuccess: false);
          
          // <<< PERBAIKAN: Simpan waktu kedaluwarsa ke SharedPreferences >>>
          final prefs = await SharedPreferences.getInstance();
          final expiryTime = DateTime.now().add(Duration(seconds: state.retryAfterSeconds));
          await prefs.setInt(_rateLimitExpiryKey, expiryTime.millisecondsSinceEpoch);
          
          _startRateLimitCountdown(state.retryAfterSeconds);

        } else if (state is AuthLoginFailure) {
          showAppFlashbar(context, title: "Login Gagal", message: state.message, isSuccess: false);
          setState(() => _pin = '');
        } else if (state is AuthForgotPinSuccess) {
          showAppFlashbar(context, title: "Permintaan Terkirim", message: "Link untuk mengatur ulang PIN telah dikirim melalui WhatsApp.", isSuccess: true);
        } else if (state is AuthForgotPinFailure) {
          showAppFlashbar(context, title: "Gagal Meminta Reset PIN", message: state.message, isSuccess: false);
        }
      },
      child: PopScope( // Ganti WillPopScope dengan PopScope untuk Flutter versi baru
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go(InitialRoutes.loginScreen);
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
      ),
    );
  }

  // ... sisa kode tidak perlu diubah ...
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
                  const Text('Selamat Datang Kembali!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Masukkan 6-digit PIN Anda untuk melanjutkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 40),
                  _buildPinInputSection(),
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
        // Panel Kiri: Informasi / Branding
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang Kembali!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Gunakan keypad di sebelah kanan untuk memasukkan 6-digit PIN Anda dan melanjutkan.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Panel Kanan: Input PIN (VERSI PERBAIKAN ANTI-OVERFLOW)
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
  
  /// Widget bersama untuk menampilkan display PIN dan tombol 'Lupa PIN'
  Widget _buildPinInputSection() {
    return Column(
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (_isRateLimited) {
              return Text('Coba lagi dalam $_rateLimitCountdownSeconds detik', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold));
            }
            return SizedBox(
              height: 48, // Beri tinggi agar layout tidak "loncat"
              child: Stack(
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
              ),
            );
          },
        ),
        _buildForgotPasswordButton(),
      ],
    );
  }

  // --- Widget Builders ---
  Widget _buildForgotPasswordButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: _isForgotPinOnCooldown
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Kirim ulang dalam $_forgotPinCountdownSeconds detik',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          : BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (p, c) => c is AuthForgotPinLoading || c is AuthForgotPinSuccess || c is AuthForgotPinFailure,
              builder: (context, state) {
                if (state is AuthForgotPinLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                  );
                }
                return TextButton(
                  onPressed: _forgotPin,
                  child: const Text('Lupa PIN?', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                );
              },
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