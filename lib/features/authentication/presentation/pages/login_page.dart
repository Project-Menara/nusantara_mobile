// File: features/authentication/presentation/pages/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/constant/color_constant.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_extra.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
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
      backgroundColor: ColorConstant.whiteColor,
      resizeToAvoidBottomInset: false,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthCheckPhoneFailure) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthCheckPhoneSuccess) {
            Navigator.of(context, rootNavigator: true).pop();

            final checkResult = state.result; // Ini adalah PhoneCheckEntity yang sudah diperbaiki
            final action = checkResult.action;

            switch (action) {
              case 'register':
                context.push(InitialRoutes.registerScreen, extra: checkResult.phoneNumber);
                break;

              case 'verify_otp':
                final extraData = RegisterExtra(
                  phoneNumber: checkResult.phoneNumber, // Sekarang tidak error
                  ttl: checkResult.ttl,                 // Sekarang tidak error
                );
                context.push(InitialRoutes.verifyNumber, extra: extraData);
                break;

              case 'verify_otp_and_create_pin':
                context.push(InitialRoutes.createPin, extra: checkResult.phoneNumber);
                break;

              case 'login':
                context.push(InitialRoutes.pinLogin, extra: checkResult.phoneNumber);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned(left: 0, right: 0, child: LoginHeaderWidget()),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: LoginFormWidget(
                      formKey: _formKey,
                      phoneController: _phoneController,
                      onLanjutkanPressed: _onLanjutkanPressed,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}