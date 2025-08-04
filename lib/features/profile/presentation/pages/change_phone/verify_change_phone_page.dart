import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class VerifyChangePhonePage extends StatefulWidget {
  final String phoneNumber;
  const VerifyChangePhonePage({super.key, required this.phoneNumber});

  @override
  State<VerifyChangePhonePage> createState() => _VerifyChangePhonePageState();
}

class _VerifyChangePhonePageState extends State<VerifyChangePhonePage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _isResendButtonActive = false;
    _countdownSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    context
        .read<ChangePhoneBloc>()
        .add(RequestChangePhoneSubmitted(newPhone: widget.phoneNumber));
    _startTimer();
  }

  void _submitVerification(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ChangePhoneBloc>().add(VerifyChangePhoneSubmitted(
            phone: widget.phoneNumber,
            code: _otpController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePhoneBloc>(),
      child: BlocListener<ChangePhoneBloc, ChangePhoneState>(
        listener: (context, state) {
          if (state is VerifyChangePhoneSuccess) {
            showAppFlashbar(context,
                title: "Berhasil",
                message: "Nomor telepon Anda berhasil diperbarui.",
                isSuccess: true);
            
            // <<< PERBAIKAN: Navigasi ke halaman home >>>
            context.go(InitialRoutes.home);

          } else if (state is VerifyChangePhoneFailure) {
            showAppFlashbar(context,
                title: "Gagal", message: state.message, isSuccess: false);
          } else if (state is RequestChangePhoneSuccess) {
             showAppFlashbar(context,
                title: "Terkirim",
                message: "Kode OTP baru telah dikirimkan.",
                isSuccess: true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Verifikasi OTP',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Masukkan Kode Verifikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kode OTP telah dikirimkan ke nomor ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 24, letterSpacing: 16),
                    decoration: InputDecoration(
                      labelText: 'Kode OTP',
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                     validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Kode OTP harus 6 digit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildResendOtpRow(),
                  const SizedBox(height: 24),
                  BlocBuilder<ChangePhoneBloc, ChangePhoneState>(
                    builder: (context, state) {
                      final isLoading = state is VerifyChangePhoneLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => _submitVerification(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white))
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
                ],
              ),
            ),
          ),
        ),
      ),
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