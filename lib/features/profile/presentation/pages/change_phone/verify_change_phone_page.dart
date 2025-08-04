import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/otp_input_widgets.dart'; // <<< TAMBAHKAN: Import OtpInputWidgets
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class VerifyChangePhonePage extends StatefulWidget {
  final String phoneNumber;
  const VerifyChangePhonePage({super.key, required this.phoneNumber});

  @override
  State<VerifyChangePhonePage> createState() => _VerifyChangePhonePageState();
}

class _VerifyChangePhonePageState extends State<VerifyChangePhonePage> {
  String _otpCode = '';
  final int _otpLength = 6;

  Timer? _timer;
  int _countdownSeconds = 60;
  bool _isResendButtonActive = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onNumpadTapped(String value) {
    if (_otpCode.length < _otpLength) {
      setState(() {
        _otpCode += value;
      });
      // Auto-submit saat OTP sudah lengkap
      if (_otpCode.length == _otpLength) {
        _submitVerification(context);
      }
    }
  }

  void _onBackspaceTapped() {
    if (_otpCode.isNotEmpty) {
      setState(() {
        _otpCode = _otpCode.substring(0, _otpCode.length - 1);
      });
    }
  }

  void _startTimer() {
    // Logika timer tidak berubah
    _isResendButtonActive = false;
    _countdownSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResendButtonActive = true;
        });
      }
    });
  }

  void _resendOtp() {
    context.read<ChangePhoneBloc>().add(
      RequestChangePhoneSubmitted(newPhone: widget.phoneNumber),
    );
    _startTimer();
  }

  // --- PERUBAHAN: Hapus validasi form, langsung gunakan _otpCode ---
  void _submitVerification(BuildContext context) {
    if (_otpCode.length == _otpLength) {
      context.read<ChangePhoneBloc>().add(
        VerifyChangePhoneSubmitted(phone: widget.phoneNumber, code: _otpCode),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePhoneBloc>(),
      child: BlocListener<ChangePhoneBloc, ChangePhoneState>(
        listener: (context, state) {
          if (state is VerifyChangePhoneSuccess) {
            showAppFlashbar(
              context,
              title: "Berhasil",
              message: "Nomor telepon Anda berhasil diperbarui.",
              isSuccess: true,
            );
            context.go(InitialRoutes.home);
          } else if (state is VerifyChangePhoneFailure) {
            showAppFlashbar(
              context,
              title: "Gagal",
              message: state.message,
              isSuccess: false,
            );
          } else if (state is RequestChangePhoneSuccess) {
            showAppFlashbar(
              context,
              title: "Terkirim",
              message: "Kode OTP baru telah dikirimkan.",
              isSuccess: true,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Verifikasi OTP',
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
          // --- PERUBAHAN: Gunakan Column untuk memisahkan konten dan keypad ---
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  // --- PERUBAHAN: Hapus widget Form dan FormKey ---
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      const Text(
                        'Masukkan Kode Verifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kode OTP telah dikirimkan ke nomor ${widget.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // --- PERUBAHAN: Ganti TextFormField dengan UI display OTP ---
                      _buildOtpDisplay(),
                      const SizedBox(height: 24),
                      _buildResendOtpRow(),
                      const SizedBox(height: 24),
                      BlocBuilder<ChangePhoneBloc, ChangePhoneState>(
                        builder: (context, state) {
                          final isLoading = state is VerifyChangePhoneLoading;
                          return ElevatedButton(
                            // --- PERUBAHAN: Kondisi onPressed disesuaikan ---
                            onPressed:
                                (_otpCode.length == _otpLength && !isLoading)
                                ? () => _submitVerification(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              disabledBackgroundColor: Colors.orange
                                  .withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Verifikasi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              // --- TAMBAHKAN: Widget keypad custom di bagian bawah ---
              OtpInputWidgets(
                onNumpadTapped: _onNumpadTapped,
                onBackspaceTapped: _onBackspaceTapped,
                otpCode: _otpCode,
                otpLength: _otpLength,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAMBAHKAN: Widget untuk menampilkan kotak/lingkaran OTP ---
  Widget _buildOtpDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _otpLength; i++) {
      displayWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: i < _otpCode.length ? Colors.orange : Colors.grey[300],
              shape: BoxShape.circle,
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

  Widget _buildResendOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          !_isResendButtonActive
              ? 'Kirim ulang dalam 00:${_countdownSeconds.toString().padLeft(2, '0')}'
              : 'Tidak menerima kode?',
          style: const TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: _isResendButtonActive ? _resendOtp : null,
          child: const Text('Kirim Ulang'),
        ),
      ],
    );
  }
}
