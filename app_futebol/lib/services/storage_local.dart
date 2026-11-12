import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_futebol/models/item_futebol.dart';
import 'package:app_futebol/models/clube_futebol.dart';

// Informações da sessão do torcedor
String torcedorNome = '';
String torcedorCpf = '';
String torcedorClube = '';
String torcedorCep = '';
String torcedorEndereco = '';
List<String> sacolaIds = [];

// Endereço oficial do servidor em nuvem
const String apiBaseUrl = 'https://api-mercadinho-ppdm.onrender.com';

class StorageLocal {
  // Carrega configurações e dados do torcedor salvos no dispositivo
  static Future<void> carregarDadosLocais() async {
    final preferencias = await SharedPreferences.getInstance();
    torcedorNome = preferencias.getString('torcedor_nome') ?? '';
    torcedorCpf = preferencias.getString('torcedor_cpf') ?? '';
    torcedorClube = preferencias.getString('torcedor_clube') ?? '';
    torcedorCep = preferencias.getString('torcedor_cep') ?? '';
    torcedorEndereco = preferencias.getString('torcedor_endereco') ?? '';
    sacolaIds = preferencias.getStringList('sacola_ids') ?? <String>[];
  }

  // Salva dados pessoais do torcedor
  static Future<void> salvarDadosTorcedor({
    required String nome,
    required String cpf,
    required String clube,
    required String cep,
    required String endereco,
    String? urlApi,
  }) async {
    torcedorNome = nome;
    torcedorCpf = cpf;
    torcedorClube = clube;
    torcedorCep = cep;
    torcedorEndereco = endereco;

    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('torcedor_nome', torcedorNome);
    await preferencias.setString('torcedor_cpf', torcedorCpf);
    await preferencias.setString('torcedor_clube', torcedorClube);
    await preferencias.setString('torcedor_cep', torcedorCep);
    await preferencias.setString('torcedor_endereco', torcedorEndereco);
  }

  // Adiciona ou remove item da sacola
  static Future<bool> alternarItemSacola(String idProduto) async {
    final preferencias = await SharedPreferences.getInstance();
    final bool adicionado;
    if (sacolaIds.contains(idProduto)) {
      sacolaIds.remove(idProduto);
      adicionado = false;
    } else {
      sacolaIds.add(idProduto);
      adicionado = true;
    }
    await preferencias.setStringList('sacola_ids', sacolaIds);
    return adicionado;
  }

  // Remove produto da sacola
  static Future<void> removerItemSacola(String idProduto) async {
    final preferencias = await SharedPreferences.getInstance();
    sacolaIds.remove(idProduto);
    await preferencias.setStringList('sacola_ids', sacolaIds);
  }

  // Executa requisição com tempo limite de segurança
  static Future<http.Response> executarHttp(
    Future<http.Response> Function() chamada, {
    Duration tempoLimite = const Duration(seconds: 10),
  }) async {
    return await chamada().timeout(tempoLimite);
  }

  // Testa conexão com o servidor
  static Future<Map<String, dynamic>> testarConexaoApi(String url) async {
    final urlFormatada = url.trim().replaceAll(RegExp(r'/+$'), '');
    final cronometro = Stopwatch()..start();
    try {
      final uri = Uri.parse('$urlFormatada/produtos');
      final resposta = await http.get(uri).timeout(const Duration(seconds: 8));
      cronometro.stop();

      if (resposta.statusCode == 200) {
        return {
          'sucesso': true,
          'tempoMs': cronometro.elapsedMilliseconds,
          'mensagem':
              'Conexão estabelecida com sucesso (${cronometro.elapsedMilliseconds}ms)!',
        };
      } else {
        return {
          'sucesso': false,
          'tempoMs': cronometro.elapsedMilliseconds,
          'mensagem': 'O servidor respondeu com status ${resposta.statusCode}',
        };
      }
    } catch (erro) {
      cronometro.stop();
      return {
        'sucesso': false,
        'tempoMs': cronometro.elapsedMilliseconds,
        'mensagem': 'Não foi possível conectar: $erro',
      };
    }
  }

  // ==========================================
  // OPERAÇÕES DE PRODUTOS NO SERVIDOR
  // ==========================================

  // Busca todos os produtos cadastrados
  static Future<List<ItemFutebol>> buscarProdutosApi() async {
    final url = Uri.parse('$apiBaseUrl/produtos');
    final resposta = await executarHttp(() => http.get(url));

    if (resposta.statusCode == 200) {
      final List dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      return dados
          .map((e) => ItemFutebol.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Falha ao carregar produtos (Código ${resposta.statusCode})');
    }
  }

  // Cadastra um novo produto
  static Future<ItemFutebol> criarProdutoApi(Map<String, dynamic> dadosProduto) async {
    final url = Uri.parse('$apiBaseUrl/produtos');
    final resposta = await executarHttp(
      () => http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dadosProduto),
      ),
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      return ItemFutebol.fromJson(Map<String, dynamic>.from(dados));
    } else {
      throw Exception('Falha ao cadastrar produto (Código ${resposta.statusCode})');
    }
  }

  // Atualiza um produto existente
  static Future<ItemFutebol> atualizarProdutoApi(
    String id,
    Map<String, dynamic> dadosProduto,
  ) async {
    final url = Uri.parse('$apiBaseUrl/produtos/$id');
    final resposta = await executarHttp(
      () => http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dadosProduto),
      ),
    );

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      return ItemFutebol.fromJson(Map<String, dynamic>.from(dados));
    } else {
      throw Exception('Falha ao atualizar produto (Código ${resposta.statusCode})');
    }
  }

  // Exclui um produto
  static Future<void> excluirProdutoApi(String id) async {
    final url = Uri.parse('$apiBaseUrl/produtos/$id');
    final resposta = await executarHttp(() => http.delete(url));

    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw Exception('Falha ao excluir produto (Código ${resposta.statusCode})');
    }
  }

  // ==========================================
  // OPERAÇÕES DE CLUBES NO SERVIDOR
  // ==========================================

  // Busca lista de clubes cadastrados
  static Future<List<ClubeFutebol>> buscarClubesApi() async {
    final url = Uri.parse('$apiBaseUrl/clubes');
    final resposta = await executarHttp(() => http.get(url));

    if (resposta.statusCode == 200) {
      final List dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      return dados
          .map((e) => ClubeFutebol.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Falha ao carregar clubes (Código ${resposta.statusCode})');
    }
  }
}
