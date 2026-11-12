import 'package:flutter/material.dart';
import 'package:app_futebol/models/item_futebol.dart';

class CardProdutoFutebol extends StatelessWidget {
  final ItemFutebol item;
  final bool naSacola;
  final VoidCallback onAlternarSacola;

  const CardProdutoFutebol({
    super.key,
    required this.item,
    required this.naSacola,
    required this.onAlternarSacola,
  });

  @override
  Widget build(BuildContext context) {
    final double precoFinal = item.calcularPrecoFinal();
    final bool promocao = item.emPromocao;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: naSacola ? const Color(0xFF0D6E3A) : const Color(0xFFE5E7EB),
          width: naSacola ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Uniforme/Produto + Escudo Oficial do Clube no canto
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Image.network(
                    item.urlImagemSegura,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.sports_soccer_rounded,
                      color: Color(0xFF0D6E3A),
                      size: 40,
                    ),
                  ),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF0D6E3A),
                        width: 1.5,
                      ),
                    ),
                    child: Image.network(
                      item.urlLogoSegura,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFF0D6E3A),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        item.urlLogoSegura,
                        width: 20,
                        height: 20,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: Color(0xFF0D6E3A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: promocao
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.seloDestaque(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: promocao
                                ? const Color(0xFFB45309)
                                : const Color(0xFF0D6E3A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (promocao)
                            Text(
                              'R\$ ${item.preco.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            'R\$ ${precoFinal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D6E3A),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: naSacola
                              ? const Color(0xFF111827)
                              : const Color(0xFF0D6E3A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onAlternarSacola,
                        icon: Icon(
                          naSacola
                              ? Icons.check_circle_rounded
                              : Icons.add_shopping_cart_rounded,
                          size: 18,
                        ),
                        label: Text(naSacola ? 'Na Sacola' : 'Adicionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
