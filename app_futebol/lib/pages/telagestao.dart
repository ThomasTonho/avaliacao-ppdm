import 'package:flutter/material.dart';
import 'package:app_futebol/components/minhaappbar.dart';
import 'package:app_futebol/models/item_futebol.dart';
import 'package:app_futebol/services/storage_local.dart';

class TelaGestao extends StatefulWidget {
  const TelaGestao({super.key});

  @override
  State<TelaGestao> createState() => _TelaGestaoState();
}

class _TelaGestaoState extends State<TelaGestao> {
  final TextEditingController nomeDigitado = TextEditingController();
  final TextEditingController categoriaDigitada =
      TextEditingController(text: 'Camisas');
  final TextEditingController clubeDigitado =
      TextEditingController(text: 'Flamengo');
  final TextEditingController urlDigitada = TextEditingController(
    text:
        'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600&auto=format&fit=crop&q=80',
  );
  final TextEditingController precoDigitado = TextEditingController();
  final TextEditingController descontoDigitado =
      TextEditingController(text: '0');
  final TextEditingController descricaoDigitada = TextEditingController(
    text: 'Artigo oficial de futebol com garantia e nota fiscal.',
  );

  List<ItemFutebol> listaProdutos = [];
  String? idEmEdicao;
  bool carregando = false;
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  // Busca os produtos
  Future<void> carregarProdutos() async {
    setState(() => carregando = true);
    try {
      final itens = await StorageLocal.buscarProdutosApi();
      if (mounted) {
        setState(() {
          listaProdutos = itens;
          carregando = false;
        });
      }
    } catch (erro) {
      if (mounted) {
        setState(() => carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text(
              'Erro ao carregar dados: ${erro.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Map<String, dynamic> _montarDados([String? id]) {
    final int desconto = int.tryParse(descontoDigitado.text.trim()) ?? 0;
    final double preco =
        double.tryParse(precoDigitado.text.replaceAll(',', '.').trim()) ?? 0.0;

    final mapa = <String, dynamic>{
      'nome': nomeDigitado.text.trim(),
      'categoria': categoriaDigitada.text.trim().isEmpty
          ? 'Camisas'
          : categoriaDigitada.text.trim(),
      'clube': clubeDigitado.text.trim().isEmpty
          ? 'Oficial'
          : clubeDigitado.text.trim(),
      'tipo': desconto > 0 ? 'promocao' : 'regular',
      'desconto': desconto,
      'preco': preco,
      'imagem': urlDigitada.text.trim(),
      'logoClube': obterLogoPadraoPorClube(clubeDigitado.text.trim()),
      'descricao': descricaoDigitada.text.trim(),
    };

    if (id != null) {
      mapa['id'] = id;
    }
    return mapa;
  }

  bool _validarFormulario() {
    if (nomeDigitado.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Informe o nome do produto!'),
        ),
      );
      return false;
    }
    final preco = double.tryParse(precoDigitado.text.replaceAll(',', '.').trim());
    if (preco == null || preco <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Informe um preço numérico válido maior que zero!'),
        ),
      );
      return false;
    }
    return true;
  }

  // Cadastra novo produto
  Future<void> cadastrarProduto() async {
    if (!_validarFormulario()) return;

    setState(() => enviando = true);
    final novoId = DateTime.now().millisecondsSinceEpoch.toString();
    final dados = _montarDados(novoId);

    try {
      await StorageLocal.criarProdutoApi(dados);
      if (!mounted) return;
      _limparCampos();
      await carregarProdutos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0D6E3A),
          content: Text('Produto cadastrado com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Falha ao cadastrar: ${erro.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  // Atualiza produto
  Future<void> atualizarProduto(String id) async {
    if (!_validarFormulario()) return;

    setState(() => enviando = true);
    final dados = _montarDados(id);

    try {
      await StorageLocal.atualizarProdutoApi(id, dados);
      if (!mounted) return;
      _limparCampos();
      await carregarProdutos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0D6E3A),
          content: Text('Produto atualizado com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Falha ao atualizar: ${erro.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  // Exclui produto
  Future<void> excluirProduto(ItemFutebol item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${item.nome}" do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => carregando = true);
    try {
      await StorageLocal.excluirProdutoApi(item.id);
      if (sacolaIds.contains(item.id)) {
        await StorageLocal.removerItemSacola(item.id);
      }
      if (!mounted) return;
      await carregarProdutos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0D6E3A),
          content: Text('Produto "${item.nome}" removido com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Falha ao excluir: ${erro.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    }
  }

  void _editarItem(ItemFutebol item) {
    setState(() {
      idEmEdicao = item.id;
      nomeDigitado.text = item.nome;
      categoriaDigitada.text = item.categoria;
      clubeDigitado.text = item.clube;
      urlDigitada.text = item.imagem;
      precoDigitado.text = item.preco.toStringAsFixed(2);
      descontoDigitado.text =
          item is ProdutoPromocao ? item.percentualDesconto.toString() : '0';
      descricaoDigitada.text = item.descricao;
    });
  }

  void _limparCampos() {
    setState(() {
      idEmEdicao = null;
      nomeDigitado.clear();
      precoDigitado.clear();
      descontoDigitado.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final editando = idEmEdicao != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const MinhaAppBar(titulo: 'Gestão de Produtos'),
      body: RefreshIndicator(
        color: const Color(0xFF0D6E3A),
        onRefresh: carregarProdutos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          editando ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                          color: const Color(0xFF0D6E3A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          editando
                              ? 'Editar Produto'
                              : 'Cadastrar Novo Produto',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nomeDigitado,
                      decoration: const InputDecoration(
                        labelText: 'Nome do produto ou serviço *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: categoriaDigitada,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: clubeDigitado,
                            decoration: const InputDecoration(
                              labelText: 'Clube ou Marca',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: precoDigitado,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Preço (R\$) *',
                              hintText: 'ex: 299.90',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: descontoDigitado,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Desconto %',
                              hintText: '0',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlDigitada,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descricaoDigitada,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6E3A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: enviando
                                ? null
                                : () {
                                    if (editando) {
                                      atualizarProduto(idEmEdicao!);
                                    } else {
                                      cadastrarProduto();
                                    }
                                  },
                            icon: enviando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(editando ? Icons.save : Icons.add),
                            label: Text(
                              enviando
                                  ? 'Salvando...'
                                  : (editando ? 'Salvar Alterações' : 'Cadastrar Produto'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (editando) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _limparCampos,
                            tooltip: 'Cancelar edição',
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catálogo de Produtos',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  '${listaProdutos.length} itens',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (carregando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D6E3A)),
                ),
              )
            else if (listaProdutos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhum item encontrado no catálogo.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              )
            else
              for (final prod in listaProdutos)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Image.network(
                      prod.urlLogoSegura,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_soccer,
                        color: Color(0xFF0D6E3A),
                      ),
                    ),
                    title: Text(
                      prod.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${prod.seloDestaque()} • R\$ ${prod.calcularPrecoFinal().toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => _editarItem(prod),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => excluirProduto(prod),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
