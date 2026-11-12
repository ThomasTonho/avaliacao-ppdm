import 'package:flutter/material.dart';
import 'package:app_futebol/components/components.dart';
import 'package:app_futebol/components/minhaappbar.dart';
import 'package:app_futebol/models/item_futebol.dart';
import 'package:app_futebol/pages/telagestao.dart';
import 'package:app_futebol/services/storage_local.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  List<ItemFutebol> listaProdutos = [];
  String categoriaAtiva = 'Todos';
  bool carregando = true;
  String? mensagemErro;

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  // Carrega lista de produtos
  Future<void> carregarProdutos() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final itens = await StorageLocal.buscarProdutosApi();
      if (mounted) {
        setState(() {
          listaProdutos = itens;
          carregando = false;
          mensagemErro = null;
        });
      }
    } catch (erro) {
      if (mounted) {
        setState(() {
          listaProdutos = [];
          carregando = false;
          mensagemErro = erro.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _alternarSacola(ItemFutebol item) async {
    final adicionado = await StorageLocal.alternarItemSacola(item.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            adicionado ? const Color(0xFF0D6E3A) : const Color(0xFF111827),
        content: Text(
          adicionado
              ? '"${item.nome}" adicionado à sacola!'
              : 'Item removido da sacola.',
        ),
      ),
    );
  }

  List<ItemFutebol> get _produtosFiltrados {
    if (categoriaAtiva == 'Todos') return listaProdutos;
    if (categoriaAtiva == 'Ofertas') {
      return listaProdutos.where((p) => p.emPromocao).toList();
    }
    return listaProdutos
        .where((p) => p.categoria.toLowerCase() == categoriaAtiva.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibicao = torcedorNome.trim().isNotEmpty
        ? torcedorNome.trim()
        : 'Torcedor(a)';
    final clubeExibicao = torcedorClube.trim().isNotEmpty
        ? torcedorClube.trim()
        : 'Futebol';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: MinhaAppBar(
        titulo: 'Arena FutStore',
        mostrarVoltar: false,
        acoesExtras: [
          IconButton(
            tooltip: 'Gestão de Produtos',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaGestao()),
              );
              carregarProdutos();
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0D6E3A),
        onRefresh: carregarProdutos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D6E3A), Color(0xFF064E28)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fala, $nomeExibicao!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clube: $clubeExibicao • Confira mantos oficiais, novidades e quadras society.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF5B800),
                    size: 42,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Todos',
                  'Ofertas',
                  'Camisas',
                  'Chuteiras',
                  'Equipamentos',
                  'Quadra',
                ].map((categoria) {
                  final ativo = categoriaAtiva == categoria;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        categoria,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ativo ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      selected: ativo,
                      selectedColor: const Color(0xFF0D6E3A),
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => categoriaAtiva = categoria),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (carregando)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0D6E3A)),
                      SizedBox(height: 14),
                      Text(
                        'Carregando produtos...',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (mensagemErro != null)
              Card(
                color: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Color(0xFFDC2626),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Não foi possível carregar os produtos',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mensagemErro!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: carregarProdutos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6E3A),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_produtosFiltrados.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhum produto cadastrado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Cadastre o primeiro artigo esportivo na área de Gestão!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaGestao(),
                            ),
                          );
                          carregarProdutos();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6E3A),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Cadastrar Novo Produto'),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final item in _produtosFiltrados)
                CardProdutoFutebol(
                  item: item,
                  naSacola: sacolaIds.contains(item.id),
                  onAlternarSacola: () => _alternarSacola(item),
                ),
          ],
        ),
      ),
    );
  }
}
