import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/otp_input_widgets.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class VerifyNumberPage extends StatelessWidget {
  final String phoneNumber;
  final int ttl;
  final String action;

  const VerifyNumberPage({
    super.key,
    required this.phoneNumber,
    required this.ttl,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OtpBloc>(),
      child: VerifyNumberView(
        phoneNumber: phoneNumber,
        ttl: ttl,
        action: action,
      ),
    );
  }
}

class VerifyNumberView extends StatefulWidget {
  final String phoneNumber;
  final int ttl;
  final String action;

  const VerifyNumberView({
    super.key,
    required this.phoneNumber,
    required this.ttl,
    required this.action,
  });

  @override
  State<VerifyNumberView> createState() => _VerifyNumberViewState();
}

class _VerifyNumberViewState extends State<VerifyNumberView> {
  String _otpCode = '';
  final int _otpLength = 6;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.ttl;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = widget.ttl);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onNumpadTapped(String value) {
    if (_otpCode.length < _otpLength) {
      setState(() => _otpCode += value);
    }
  }

  void _onBackspaceTapped() {
    if (_otpCode.isNotEmpty) {
      setState(() => _otpCode = _otpCode.substring(0, _otpCode.length - 1));
    }
  }

  void _submitOtp() {
    context.read<OtpBloc>().add(
          OtpSubmitted(phoneNumber: widget.phoneNumber, code: _otpCode),
        );
  }

  void _resendOtp() {
    context.read<OtpBloc>().add(
          OtpResendRequested(phoneNumber: widget.phoneNumber),
        );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Verifikasi Nomor',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.go(InitialRoutes.loginScreen),
      ),
    );

    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          showAppFlashbar(
            context,
            title: 'Verifikasi Berhasil',
            message: 'Nomor Anda telah terverifikasi.',
            isSuccess: true,
          );
          if (widget.action == 'verify_otp_and_create_pin') {
            context.push(InitialRoutes.createPin, extra: widget.phoneNumber);
          } else {
            context.push(InitialRoutes.pinLogin, extra: widget.phoneNumber);
          }
        } else if (state is OtpVerificationFailure) {
          showAppFlashbar(
            context,
            title: 'Verifikasi Gagal',
            message: state.message,
            isSuccess: false,
          );
        } else if (state is OtpResendSuccess) {
          _startTimer();
          showAppFlashbar(
            context,
            title: 'Mengirim Ulang',
            message: 'Kode OTP baru telah dikirim.',
            isSuccess: true,
          );
        } else if (state is OtpResendFailure) {
          showAppFlashbar(
            context,
            title: 'Gagal Mengirim Ulang',
            message: state.message,
            isSuccess: false,
          );
        }
      },
      // --- PERBAIKAN: Ganti WillPopScope menjadi PopScope ---
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go(InitialRoutes.loginScreen);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: appBar,
          // --- PERBAIKAN UTAMA: Menggunakan layout scrollable ---
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    appBar.preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // === Bagian Atas: Konten Informasi ===
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Verifikasi Nomor Anda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Masukkan 6 digit kode OTP yang dikirimkan ke nomor ${widget.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 60),
                        _buildOtpDisplay(),
                        const SizedBox(height: 30),
                        _resendCodeSection(),
                        const SizedBox(height: 60),
                        BlocBuilder<OtpBloc, OtpState>(
                          builder: (context, state) {
                            final isLoading = state is OtpVerificationLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    (_otpCode.length == _otpLength && !isLoading)
                                        ? _submitOtp
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  disabledBackgroundColor:
                                      Colors.orange.withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                                          strokeWidth: 3,
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
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // === Bagian Bawah: Keypad Input ===
                  OtpInputWidgets(
                    otpCode: _otpCode,
                    onNumpadTapped: _onNumpadTapped,
                    onBackspaceTapped: _onBackspaceTapped,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget _resendCodeSection() {
    return Column(
      children: [
        if (_remainingSeconds > 0)
          Text(
            'Kirim ulang kode dalam ${_formatTime(_remainingSeconds)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          )
        else
          BlocBuilder<OtpBloc, OtpState>(
            buildWhen: (previous, current) {
              return current is OtpResendLoading ||
                  current is OtpResendSuccess ||
                  current is OtpResendFailure ||
                  previous is OtpResendLoading;
            },
            builder: (context, state) {
              if (state is OtpResendLoading) {
                return const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                );
              }
              return TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Kirim Ulang Kode',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOtpDisplay() {
    List<Widget> displayWidgets = [];
    for (int i = 0; i < _otpLength; i++) {
      displayWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            width: 45,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: i < _otpCode.length
                ? Text(
                    _otpCode[i],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : null,
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