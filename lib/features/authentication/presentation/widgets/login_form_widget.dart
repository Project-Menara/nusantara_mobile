import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final VoidCallback onLanjutkanPressed;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.onLanjutkanPressed,
  });

  static const Color primaryOrange = Color(0xFFF57C00);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "MASUKKAN NOMOR TELEPON ANDA",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Anda dapat masuk atau membuat akun baru di Aplikasi Nusantara Oleh Oleh",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Nomor Telepon",
                style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              // --- PERBAIKAN: Bungkus Row dengan Container untuk border ---
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Text(
                        '+62 ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "81234567890",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          // Hapus border dari TextFormField agar menyatu
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, // Dihapus karena sudah ada padding di Row
                            vertical: 14, // Atur tinggi vertikal
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          if (value.startsWith('0')) {
                            return 'Nomor telepon tidak boleh diawali 0';
                          }
                          if (value.length < 9 || value.length > 13) {
                            return 'Nomor telepon harus 9 sampai 13 digit';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Hanya boleh berisi angka';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  // <<< PERBAIKAN: Ganti AuthLoading menjadi AuthCheckPhoneLoading >>>
                  final isLoading = state is AuthCheckPhoneLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : onLanjutkanPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Lanjutkan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go(InitialRoutes.home),
                  style: TextButton.styleFrom(foregroundColor: primaryOrange),
                  child: const Text(
                    "Lanjut sebagai Tamu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}