import 'package:flutter/material.dart';
import 'package:app_futebol/navigation/navbar.dart';
import 'package:app_futebol/services/storage_local.dart';

class MinhaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final bool mostrarVoltar;
  final List<Widget>? acoesExtras;

  const MinhaAppBar({
    super.key,
    this.titulo = 'Arena FutStore',
    this.mostrarVoltar = true,
    this.acoesExtras,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D6E3A),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5B800), width: 3),
        ),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            if (mostrarVoltar)
              IconButton(
                tooltip: 'Voltar para a vitrine',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Navbar()),
                ),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            const Icon(Icons.sports_soccer_rounded,
                color: Color(0xFFF5B800), size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_rounded,
                      color: Color(0xFFF5B800), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${sacolaIds.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ...?acoesExtras,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 3);
}
