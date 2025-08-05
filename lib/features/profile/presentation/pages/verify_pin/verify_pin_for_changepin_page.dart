import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/pin_input_widgets.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/verify_pin/verify_pin_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class VerifyPinForChangePinPage extends StatelessWidget {
  const VerifyPinForChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyPinBloc>(),
      child: const VerifyPinForChangePinView(),
    );
  }
}

class VerifyPinForChangePinView extends StatefulWidget {
  const VerifyPinForChangePinView({super.key});

  @override
  State<VerifyPinForChangePinView> createState() =>
      _VerifyPinForChangePinViewState();
}

class _VerifyPinForChangePinViewState extends State<VerifyPinForChangePinView> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isPinVisible = false;

  void _onNumpadTapped(String value) {
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

  void _submitPin() {
    context.read<VerifyPinBloc>().add(VerifyPinSubmitted(pin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyPinBloc, VerifyPinState>(
      listener: (context, state) {
        if (state is VerifyPinSuccess) {
          context.pushReplacement(InitialRoutes.newPin);
        } else if (state is VerifyPinFailure) {
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
        // <<< PERBAIKAN: AppBar disesuaikan dengan gaya CreatePinPage >>>
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
        // <<< PERBAIKAN: Body disesuaikan dengan layout CreatePinPage >>>
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const Spacer(),
                    const Text(
                      'Masukkan PIN Keamanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verifikasi PIN Anda saat ini untuk dapat membuat PIN baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 60),
                    _buildPinInputSection(), // Ini berisi display PIN atau loading
                    // Tombol "Lanjutkan" sengaja tidak ada di sini,
                    // karena halaman ini menggunakan auto-submit.
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
    );
  }

  Widget _buildPinInputSection() {
    return BlocBuilder<VerifyPinBloc, VerifyPinState>(
      builder: (context, state) {
        if (state is VerifyPinLoading) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }
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