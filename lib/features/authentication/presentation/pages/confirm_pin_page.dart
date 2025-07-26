import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class ConfirmPinPage extends StatefulWidget {
  final String phoneNumber;
  final String firstPin;

  const ConfirmPinPage({
    super.key,
    required this.phoneNumber,
    required this.firstPin,
  });

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
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

  void _confirmAndSavePin() {
    if (_pin != widget.firstPin) {
      showAppFlashbar(
        context,
        title: 'PIN Tidak Cocok',
        message: 'PIN yang Anda masukkan tidak sama. Coba lagi.',
        isSuccess: false,
      );
      setState(() => _pin = '');
      return;
    }
    context.read<PinBloc>().add(
      CreatePinSubmitted(phoneNumber: widget.phoneNumber, pin: _pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PinBloc>(),
      child: BlocListener<PinBloc, PinState>(
        listener: (context, state) {
          if (state is PinCreationSuccess) {
            showAppFlashbar(
              context,
              title: 'Berhasil!',
              message: 'PIN Anda berhasil dibuat.',
              isSuccess: true,
            );
            context.go(InitialRoutes.home);
          } else if (state is PinCreationFailure) {
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Confirm Your PIN',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
                      const Text(
                        'Confirm Your PIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Re-enter your PIN to confirm.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
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
                      BlocBuilder<PinBloc, PinState>(
                        builder: (context, state) {
                          final isLoading = state is PinCreationLoading;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_pin.length == _pinLength && !isLoading)
                                  ? _confirmAndSavePin
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
                                      'Confirm & Save',
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
    );
  }

  // Logika di dalam _buildPinDisplay diubah total
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
