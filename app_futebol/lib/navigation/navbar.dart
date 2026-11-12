import 'package:flutter/material.dart';
import 'package:app_futebol/pages/telaclubes.dart';
import 'package:app_futebol/pages/telahome.dart';
import 'package:app_futebol/pages/telaperfil.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int indexAtual = 0;

  void mudarIndex(int novoIndex) {
    setState(() {
      indexAtual = novoIndex;
    });
  }

  final List<Widget> paginas = const [
    TelaHome(),
    TelaClubes(),
    TelaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: paginas.elementAt(indexAtual),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexAtual,
        onTap: mudarIndex,
        backgroundColor: const Color(0xFF0D6E3A),
        selectedItemColor: const Color(0xFFF5B800),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            label: 'Loja & Arena',
            icon: Icon(Icons.storefront_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Clubes',
            icon: Icon(Icons.shield_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Dados & Sacola',
            icon: Icon(Icons.person_pin_rounded),
          ),
        ],
      ),
    );
  }
}
