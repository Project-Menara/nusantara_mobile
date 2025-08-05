import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
// Import widget keypad baru kita
import 'package:nusantara_mobile/features/authentication/presentation/widgets/phone_input_widgets.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  String _phoneNumber = '';
  final int _phoneLengthMin = 9;
  final int _phoneLengthMax = 13;

  void _onNumpadTapped(String value) {
    if (_phoneNumber.length < _phoneLengthMax) {
      setState(() {
        _phoneNumber += value;
      });
    }
  }

  void _onBackspaceTapped() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _submitRequest(BuildContext context) {
    if (_phoneNumber.length < _phoneLengthMin) {
      showAppFlashbar(
        context,
        title: "Gagal",
        message: "Nomor telepon terlalu pendek.",
        isSuccess: false,
      );
      return;
    }

    final fullPhoneNumber = '+62$_phoneNumber';
    context.read<ChangePhoneBloc>().add(
          RequestChangePhoneSubmitted(newPhone: fullPhoneNumber),
        );
  }

  // --- TAMBAHAN: Method untuk menampilkan dialog konfirmasi ---
  Future<void> _showCancelConfirmationDialog() async {
    // Tampilkan dialog dan tunggu hasilnya (true jika "Ya", null/false jika "Tidak")
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Pengguna harus memilih salah satu tombol
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Perubahan?'),
          content: const Text(
              'Apakah Anda yakin ingin membatalkan proses ubah nomor telepon?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                // Tutup dialog dan kembalikan nilai 'false'
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Ya, Batalkan'),
              onPressed: () {
                // Tutup dialog dan kembalikan nilai 'true'
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    // Jika pengguna menekan "Ya, Batalkan" (shouldCancel == true)
    if (shouldCancel == true && mounted) {
      // Kembali ke halaman profil (data personal)
      // Sesuaikan InitialRoutes.profile jika nama rutenya berbeda
      context.go(InitialRoutes.profile);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text(
        'Ubah Nomor Telepon',
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
        // --- PERBAIKAN: Panggil method dialog saat tombol AppBar ditekan ---
        onPressed: _showCancelConfirmationDialog,
      ),
    );

    return BlocProvider(
      create: (context) => sl<ChangePhoneBloc>(),
      child: BlocListener<ChangePhoneBloc, ChangePhoneState>(
        listener: (context, state) {
          if (state is RequestChangePhoneSuccess) {
            final fullPhoneNumber = '+62$_phoneNumber';
            context.push(
              InitialRoutes.confirmChangePhone,
              extra: fullPhoneNumber,
            );
          } else if (state is RequestChangePhoneFailure) {
            showAppFlashbar(
              context,
              title: "Gagal",
              message: state.message,
              isSuccess: false,
            );
          }
        },
        // --- PERBAIKAN: Bungkus Scaffold dengan PopScope ---
        child: PopScope(
          canPop: false, // Mencegah pop otomatis
          onPopInvoked: (didPop) {
            // Jika pop sudah terjadi (misalnya dari dalam sistem), jangan lakukan apa-apa
            if (didPop) return;
            // Panggil method dialog saat gestur kembali digunakan
            _showCancelConfirmationDialog();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Masukkan Nomor Telepon Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Kami akan mengirimkan kode OTP ke nomor baru Anda untuk verifikasi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          const SizedBox(height: 48),
                          _buildPhoneDisplay(),
                          const SizedBox(height: 32),
                          BlocBuilder<ChangePhoneBloc, ChangePhoneState>(
                            builder: (context, state) {
                              final isLoading =
                                  state is RequestChangePhoneLoading;
                              final isButtonEnabled =
                                  _phoneNumber.length >= _phoneLengthMin &&
                                      !isLoading;

                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isButtonEnabled
                                      ? () => _submitRequest(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    disabledBackgroundColor:
                                        Colors.orange.withOpacity(0.4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
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
                        ],
                      ),
                    ),
                    PhoneInputWidgets(
                      onNumpadTapped: _onNumpadTapped,
                      onBackspaceTapped: _onBackspaceTapped,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '+62 ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              _phoneNumber.isEmpty ? '812...' : _phoneNumber,
              style: TextStyle(
                fontSize: 18,
                color: _phoneNumber.isEmpty
                    ? Colors.grey.shade400
                    : Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}