import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
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
    // PERBAIKAN DI SINI: Bungkus MaterialApp.router dengan BlocProvider
    return BlocProvider(
      // 'create' akan mengambil instance AuthBloc dari service locator (GetIt)
      create: (_) => di.sl<AuthBloc>(),
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