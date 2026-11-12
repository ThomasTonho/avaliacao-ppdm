import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_futebol/components/minhaappbar.dart';
import 'package:app_futebol/services/storage_local.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController clubeController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();

  bool buscandoCep = false;

  @override
  void initState() {
    super.initState();
    nomeController.text = torcedorNome;
    cpfController.text = torcedorCpf;
    clubeController.text = torcedorClube;
    cepController.text = torcedorCep;
    enderecoController.text = torcedorEndereco;
  }

  Future<void> buscarCep() async {
    final cepLimpo = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Informe um CEP válido com 8 dígitos!'),
        ),
      );
      return;
    }

    setState(() => buscandoCep = true);
    try {
      final resposta = await StorageLocal.executarHttp(
        () => http.get(Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/')),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['erro'] != true && dados['erro'] != 'true') {
          setState(() {
            enderecoController.text =
                '${dados['logradouro']}, ${dados['bairro']} - ${dados['localidade']}/${dados['uf']}';
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF0D6E3A),
              content: Text('Endereço preenchido automaticamente com sucesso!'),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFDC2626),
              content: Text('CEP não localizado.'),
            ),
          );
        }
      }
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Falha ao buscar CEP: $erro'),
        ),
      );
    } finally {
      if (mounted) setState(() => buscandoCep = false);
    }
  }

  Future<void> salvarLocalmente() async {
    await StorageLocal.salvarDadosTorcedor(
      nome: nomeController.text.trim(),
      cpf: cpfController.text.trim(),
      clube: clubeController.text.trim(),
      cep: cepController.text.trim(),
      endereco: enderecoController.text.trim(),
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF0D6E3A),
        content: Text('Dados salvos no seu aparelho com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const MinhaAppBar(
        titulo: 'Meu Perfil',
        mostrarVoltar: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CARD 1: DADOS PESSOAIS & ENDEREÇO
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_pin_rounded, color: Color(0xFF0D6E3A)),
                      SizedBox(width: 8),
                      Text(
                        'Dados Pessoais & Endereço de Entrega',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Informações salvas exclusivamente no seu aparelho.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cpfController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CPF (apenas números)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: clubeController,
                    decoration: const InputDecoration(
                      labelText: 'Clube do Coração',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shield),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cepController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'CEP de Entrega',
                            hintText: 'ex: 01001000',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6E3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                        ),
                        onPressed: buscandoCep ? null : buscarCep,
                        child: Text(buscandoCep ? '...' : 'Buscar CEP'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: enderecoController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Endereço Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6E3A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: salvarLocalmente,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Salvar Dados',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // CARD 2: SACOLA DE COMPRAS
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag_rounded, color: Color(0xFF0D6E3A)),
                          SizedBox(width: 8),
                          Text(
                            'Sacola de Compras',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          '${sacolaIds.length} ${sacolaIds.length == 1 ? "item" : "itens"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF0D6E3A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sacolaIds.isEmpty
                        ? 'Sua sacola está vazia no momento.'
                        : '${sacolaIds.length} itens selecionados.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  if (sacolaIds.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      onPressed: () async {
                        for (final id in List<String>.from(sacolaIds)) {
                          await StorageLocal.removerItemSacola(id);
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.remove_shopping_cart_rounded, size: 18),
                      label: const Text('Esvaziar Sacola'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
