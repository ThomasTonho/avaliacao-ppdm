import 'package:flutter/material.dart';
import 'package:app_futebol/navigation/navbar.dart';
import 'package:app_futebol/services/storage_local.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await StorageLocal.carregarDadosLocais();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Navbar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D6E3A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer_rounded,
              size: 92,
              color: Color(0xFFF5B800),
            ),
            SizedBox(height: 16),
            Text(
              'ARENA FUTSTORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Artigos Oficiais & Locação de Quadra Society',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Color(0xFFF5B800)),
          ],
        ),
      ),
    );
  }
}
