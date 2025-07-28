import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart'; // Impor BLoC lain yang dibutuhkan
import 'package:nusantara_mobile/routes/app_router.dart';

void main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil fungsi init untuk mendaftarkan semua dependensi
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan MultiBlocProvider untuk menyediakan lebih dari satu BLoC
    return MultiBlocProvider(
      providers: [
        // 1. Provider untuk AuthBloc yang sudah ada
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        // 2. Tambahkan BLoC lain di sini, contoh: HomeBloc
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        // Anda bisa menambahkan provider lain sebanyak yang dibutuhkan
        // BlocProvider(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Nusantara Oleh-Oleh',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
        ),
        // Gunakan router yang sudah Anda buat
        routerConfig: appRoute,
      ),
    );
  }
}
