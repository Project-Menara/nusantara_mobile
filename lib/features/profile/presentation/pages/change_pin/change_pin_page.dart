import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
// <<< TAMBAHKAN: Impor file dialog konfirmasi kustom Anda >>>
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_pin/change_pin_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/widgets/confirmation_dialog.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isPinVisible = false;

  // <<< PERUBAHAN: Gunakan helper dialog kustom yang baru >>>
  Future<bool> _showExitConfirmationDialog() async {
    // Panggil helper `showConfirmationDialog` yang sudah Anda buat.
    final result = await showConfirmationDialog(
      context: context,
      title: 'Batalkan Perubahan PIN?',
      content: 'Apakah Anda yakin ingin membatalkan proses ubah PIN?',
      confirmText: 'Ya, Batalkan',
      confirmButtonColor: Colors.red, // Warna merah untuk aksi membatalkan
      icon: Icons.warning_amber_rounded,
    );
    
    // Logika return tetap sama, jika user menutup dialog, anggap false.
    return result ?? false;
  }

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
    setState(() => _isPinVisible = !_isPinVisible);
  }

  void _submitNewPin(BuildContext blocContext) {
    blocContext.read<ChangePinBloc>().add(CreatePinSubmitted(newPin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePinBloc>(),
      child: BlocListener<ChangePinBloc, ChangePinState>(
        listener: (context, state) {
          if (state is CreatePinSuccess) {
            context.push(InitialRoutes.confirmNewPin);
          } else if (state is CreatePinFailure) {
            showAppFlashbar(
              context,
              title: 'Gagal',
              message: state.message,
              isSuccess: false,
            );
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await _showExitConfirmationDialog();
            if (shouldPop && mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Ubah PIN',
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
                onPressed: () async {
                  final shouldPop = await _showExitConfirmationDialog();
                  if (shouldPop && mounted) {
                    context.pop();
                  }
                },
              ),
            ),
            body: Column(
              // ... sisa kode body tidak berubah, karena sudah memanggil method yang benar
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        const Text(
                          'Masukkan PIN Baru Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'PIN ini akan digunakan untuk masuk ke akun\ndan melakukan transaksi.',
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
                        BlocBuilder<ChangePinBloc, ChangePinState>(
                          builder: (context, state) {
                            final isLoading = state is CreatePinLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    (_pin.length == _pinLength && !isLoading)
                                        ? () => _submitNewPin(context)
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
                                        'Lanjutkan',
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