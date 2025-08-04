import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitRequest(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // <<< PERBAIKAN 2: Gabungkan '+62' dengan input pengguna saat mengirim data >>>
      final fullPhoneNumber = '+62${_phoneController.text}';
      context
          .read<ChangePhoneBloc>()
          .add(RequestChangePhoneSubmitted(newPhone: fullPhoneNumber));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePhoneBloc>(),
      child: BlocListener<ChangePhoneBloc, ChangePhoneState>(
        listener: (context, state) {
          if (state is RequestChangePhoneSuccess) {
            // Kirim nomor telepon lengkap ke halaman verifikasi
            final fullPhoneNumber = '+62${_phoneController.text}';
            context.push(InitialRoutes.confirmChangePhone, extra: fullPhoneNumber);
          } else if (state is RequestChangePhoneFailure) {
            showAppFlashbar(context,
                title: "Gagal", message: state.message, isSuccess: false);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Ubah Nomor Telepon',
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
                    'Masukkan Nomor Telepon Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kami akan mengirimkan kode OTP ke nomor baru Anda untuk verifikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '8123456789',
                      // <<< PERBAIKAN 1: Tambahkan prefix '+62' pada tampilan >>>
                      prefixText: '+62 ',
                      prefixStyle: const TextStyle(color: Colors.black, fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      if (value.length < 9) {
                        return 'Nomor telepon terlalu pendek';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<ChangePhoneBloc, ChangePhoneState>(
                    builder: (context, state) {
                      final isLoading = state is RequestChangePhoneLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => _submitRequest(context),
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
                                'Lanjutkan',
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
}