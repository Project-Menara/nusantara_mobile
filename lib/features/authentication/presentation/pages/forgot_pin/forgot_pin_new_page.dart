import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/forgot_pin_extra.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin/pin_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class ForgotPinNewPage extends StatefulWidget {
  final ForgotPinExtra extra;
  const ForgotPinNewPage({super.key, required this.extra});

  @override
  State<ForgotPinNewPage> createState() => _ForgotPinNewPageState();
}

class _ForgotPinNewPageState extends State<ForgotPinNewPage> {
  String _pin = '';
  final int _pinLength = 6;
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

  void _togglePinVisibility() {
    setState(() {
      _isPinVisible = !_isPinVisible;
    });
  }

  void _saveNewPin(BuildContext blocContext) {
    blocContext.read<PinBloc>().add(
      SetNewPinForgotSubmitted(
        token: widget.extra.token,
        phoneNumber: widget.extra.phoneNumber,
        pin: _pin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Memicu validasi token langsung saat BLoC dibuat
      create: (context) =>
          sl<PinBloc>()..add(ValidateForgotPinToken(token: widget.extra.token)),
      child: BlocListener<PinBloc, PinState>(
        listener: (context, state) {
          // Menangani jika token tidak valid dari awal
          if (state is ResetTokenInvalid) {
            showAppFlashbar(
              context,
              title: 'Sesi Kedaluwarsa',
              message: state.message,
              isSuccess: false,
            );
            // Kembali ke halaman login PIN setelah 4 detik
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) {
                context.go(
                  InitialRoutes.pinLogin,
                  extra: widget.extra.phoneNumber,
                );
              }
            });
          }
          // Menangani jika submit PIN berhasil
          else if (state is SetNewPinForgotSuccess) {
            context.push(InitialRoutes.confirmPinForgot, extra: widget.extra);
          }
          // Menangani jika token kedaluwarsa saat submit PIN
          else if (state is SetNewPinForgotTokenExpired) {
            showAppFlashbar(
              context,
              title: 'Sesi Kedaluwarsa',
              message: state.message,
              isSuccess: false,
            );
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) {
                context.go(
                  InitialRoutes.pinLogin,
                  extra: widget.extra.phoneNumber,
                );
              }
            });
          }
          // Menangani error lainnya
          else if (state is SetNewPinForgotError) {
            showAppFlashbar(
              context,
              title: 'Gagal',
              message: state.message,
              isSuccess: false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Atur Ulang PIN',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: BlocBuilder<PinBloc, PinState>(
            builder: (context, state) {
              // Saat token sedang divalidasi, tampilkan loading
              if (state is ResetTokenValidationLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              // Jika token tidak valid, tampilkan loading sampai listener menavigasikan keluar
              if (state is ResetTokenInvalid) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              // Jika token valid, tampilkan UI utama
              final isSubmitting = state is PinLoading;
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          const Spacer(),
                          const Text(
                            'Buat PIN Keamanan Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'PIN baru ini akan digunakan untuk login\nke akun Anda selanjutnya.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 60),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildPinDisplay(),
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
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_pin.length == _pinLength && !isSubmitting)
                                  ? () => _saveNewPin(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                disabledBackgroundColor: Colors.orange
                                    .withOpacity(0.4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Lanjutkan',
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
                  PinInputWidgets(
                    onNumpadTapped: isSubmitting ? (_) {} : _onNumpadTapped,
                    onBackspaceTapped: isSubmitting
                        ? () {}
                        : _onBackspaceTapped,
                  ),
                ],
              );
            },
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
