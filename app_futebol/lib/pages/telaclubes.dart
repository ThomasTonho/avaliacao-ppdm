import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_futebol/components/minhaappbar.dart';
import 'package:app_futebol/models/clube_futebol.dart';
import 'package:app_futebol/services/storage_local.dart';

class TelaClubes extends StatefulWidget {
  const TelaClubes({super.key});

  @override
  State<TelaClubes> createState() => _TelaClubesState();
}

class _TelaClubesState extends State<TelaClubes> {
  final TextEditingController buscaController = TextEditingController();
  List<ClubeFutebol> listaClubes = [];
  bool carregando = false;
  String? mensagemErro;

  @override
  void initState() {
    super.initState();
    carregarClubes();
  }

  // Carrega lista de clubes
  Future<void> carregarClubes() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final itens = await StorageLocal.buscarClubesApi();
      if (mounted) {
        setState(() {
          listaClubes = itens;
          carregando = false;
        });
      }
    } catch (erro) {
      if (mounted) {
        setState(() {
          listaClubes = [];
          carregando = false;
          mensagemErro =
              'Não foi possível carregar os clubes: ${erro.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  // Busca qualquer clube por nome
  Future<void> pesquisarClube([String? nomeClube]) async {
    if (nomeClube != null) {
      buscaController.text = nomeClube;
    }
    final termo = buscaController.text.trim();
    if (termo.isEmpty) {
      carregarClubes();
      return;
    }

    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final url = Uri.parse(
        'https://www.thesportsdb.com/api/v1/json/123/searchteams.php?t=${Uri.encodeComponent(termo)}',
      );
      final resposta = await StorageLocal.executarHttp(() => http.get(url));

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
        final List? times = dados['teams'];
        if (mounted) {
          setState(() {
            listaClubes = times != null
                ? times
                    .map((t) =>
                        ClubeFutebol.fromJson(Map<String, dynamic>.from(t as Map)))
                    .toList()
                : [];
            carregando = false;
            if (listaClubes.isEmpty) {
              mensagemErro = 'Nenhum clube encontrado para "$termo".';
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            listaClubes = [];
            carregando = false;
            mensagemErro = 'Falha na pesquisa (Código ${resposta.statusCode}).';
          });
        }
      }
    } catch (erro) {
      if (mounted) {
        setState(() {
          listaClubes = [];
          carregando = false;
          mensagemErro =
              'Falha ao buscar clube: ${erro.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _definirClubeFavorito(String nomeClube) async {
    await StorageLocal.salvarDadosTorcedor(
      nome: torcedorNome,
      cpf: torcedorCpf,
      clube: nomeClube,
      cep: torcedorCep,
      endereco: torcedorEndereco,
      urlApi: apiBaseUrl,
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D6E3A),
        content: Text(
          '$nomeClube definido como seu clube do coração!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const MinhaAppBar(
        titulo: 'Clubes & Escudos',
        mostrarVoltar: false,
      ),
      body: ListView(
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
                  const Text(
                    'Buscar Clubes de Futebol',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pesquise times do Brasil e do mundo para ver estádio e escudo oficial.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: buscaController,
                          onSubmitted: (_) => pesquisarClube(),
                          decoration: InputDecoration(
                            labelText: 'Buscar clube',
                            hintText: 'ex: Real Madrid, Santos, Arsenal...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: buscaController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      buscaController.clear();
                                      carregarClubes();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6E3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () => pesquisarClube(),
                        child: const Text('Buscar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D6E3A),
                        ),
                        onPressed: carregarClubes,
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text('Ver Clubes em Destaque'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(36),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0D6E3A)),
                    SizedBox(height: 12),
                    Text(
                      'Carregando clubes...',
                      style: TextStyle(color: Color(0xFF6B7280)),
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
                      Icons.info_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mensagemErro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F1D1D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6E3A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: carregarClubes,
                      child: const Text('Recarregar Clubes'),
                    ),
                  ],
                ),
              ),
            )
          else if (listaClubes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Nenhum clube encontrado.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            )
          else
            for (final clube in listaClubes)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          clube.urlEscudoSegura,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shield_rounded,
                            color: Color(0xFF0D6E3A),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clube.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Estádio: ${clube.estadio}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Fundação: ${clube.anoFundacao} • ${clube.pais}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (clube.uniforme.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            clube.urlUniformeSegura,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Definir como meu clube de coração',
                        onPressed: () => _definirClubeFavorito(clube.nome),
                        icon: Icon(
                          torcedorClube.trim().toLowerCase() ==
                                  clube.nome.trim().toLowerCase()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF5B800),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
