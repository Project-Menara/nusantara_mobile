import 'package:flutter/material.dart';
import 'package:nusantara_mobile/routes/app_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;

void main() async {
  // Pastikan binding siap sebelum memanggil kode native
  WidgetsFlutterBinding.ensureInitialized();
  
  // Panggil dan TUNGGU (await) sampai semua dependensi selesai didaftarkan
   di.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRoute,
      title: 'Nusantara Oleh Oleh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}