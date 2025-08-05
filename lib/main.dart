import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/otp/otp_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/pin/pin_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
// --- TAMBAHKAN IMPORT UNTUK BLOC YANG BARU ---
import 'package:nusantara_mobile/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_pin/change_pin_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/change_phone/change_phone_bloc.dart';
import 'package:nusantara_mobile/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckStatusRequested()),
        ),
        BlocProvider(create: (_) => di.sl<HomeBloc>()..add(FetchHomeData())),
        BlocProvider(create: (_) => di.sl<PinBloc>()),
        BlocProvider(create: (_) => di.sl<OtpBloc>()),
        
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<ChangePinBloc>()),
        BlocProvider(create: (_) => di.sl<ChangePhoneBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Nusantara Mobile',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
        ),
        routerConfig: appRoute,
      ),
    );
  }
}