import 'package:flutter/material.dart';
import 'package:app_futebol/pages/telasplash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arena FutStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6E3A),
          primary: const Color(0xFF0D6E3A),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
