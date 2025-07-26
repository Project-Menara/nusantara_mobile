// login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/login_header_widget.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  // Warna oranye sekarang hanya digunakan di sini sebagai background utama
  static const Color primaryOrange = Color(0xFFF57C00);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onLanjutkanPressed() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = '+62${_phoneController.text}';
      context.read<AuthBloc>().add(AuthCheckPhonePressed(phoneNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryOrange, // Background utama menjadi oranye
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCheckPhoneFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthCheckPhoneSuccess) {
            final phoneNumber = '+62${_phoneController.text}';
            final action = state.result.action;

            switch (action) {
              case 'register':
                context.push(InitialRoutes.registerScreen, extra: phoneNumber);
                break;
              case 'verify_otp':
                context.push(InitialRoutes.createPin, extra: phoneNumber);
                break;
              case 'verify_otp_and_create_pin':
                context.push(InitialRoutes.createPin, extra: phoneNumber);
                break;
              case 'login':
                context.push(InitialRoutes.pinLogin, extra: phoneNumber);
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terjadi kesalahan: Aksi tidak dikenal'),
                  ),
                );
            }
          }
        },
        // Widget utama sekarang adalah SingleChildScrollView
        child: SingleChildScrollView(
          // Menggunakan LayoutBuilder untuk mendapatkan tinggi layar
          child: ConstrainedBox(
            // Memberi tinggi minimal pada konten sebesar tinggi layar
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const LoginHeaderWidget(),
                  // Expanded akan memaksa LoginFormWidget mengisi sisa ruang
                  Expanded(
                    child: LoginFormWidget(
                      formKey: _formKey,
                      phoneController: _phoneController,
                      onLanjutkanPressed: _onLanjutkanPressed,
                    ),
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
