// Programação Orientada a Objetos: Superclasse e Subclasses com polimorfismo

String normalizarUrlImagem(String url) {
  final limpa = url.trim();
  if (limpa.isEmpty) return '';
  if (limpa.startsWith('https://wsrv.nl/')) return limpa;
  if (limpa.contains('thesportsdb.com')) {
    return 'https://wsrv.nl/?url=${Uri.encodeComponent(limpa)}';
  }
  return limpa;
}

String obterLogoPadraoPorClube(String clube) {
  final nome = clube.toLowerCase();
  if (nome.contains('flamengo')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/syptwx1473538074.png';
  }
  if (nome.contains('corinthians')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/vvuvps1473538042.png';
  }
  if (nome.contains('palmeiras')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/vsqwqp1473538105.png';
  }
  if (nome.contains('paulo')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/sxpupx1473538135.png';
  }
  if (nome.contains('real madrid')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/vwvwrw1473502969.png';
  }
  if (nome.contains('barcelona')) {
    return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/wq9sir1639406443.png';
  }
  return 'https://wsrv.nl/?url=https://r2.thesportsdb.com/images/media/team/badge/syptwx1473538074.png';
}

class ItemFutebol {
  String id;
  String nome;
  String categoria;
  String clube;
  double preco;
  String imagem;
  String logoClube;
  String descricao;

  ItemFutebol({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.clube,
    required this.preco,
    required this.imagem,
    this.logoClube = '',
    this.descricao = 'Artigo oficial para partidas e treinos de futebol.',
  });

  double calcularPrecoFinal() {
    return preco;
  }

  String seloDestaque() {
    return 'Linha Oficial';
  }

  bool get emPromocao => false;

  String get urlLogoSegura => normalizarUrlImagem(
        logoClube.isNotEmpty ? logoClube : obterLogoPadraoPorClube(clube),
      );

  String get urlImagemSegura => normalizarUrlImagem(imagem);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'clube': clube,
      'tipo': emPromocao ? 'promocao' : 'regular',
      'desconto': 0,
      'preco': preco,
      'imagem': imagem,
      'logoClube': urlLogoSegura,
      'descricao': descricao,
    };
  }

  factory ItemFutebol.fromJson(Map<String, dynamic> json) {
    final String tipo = (json['tipo'] ?? 'regular').toString();
    final int desconto = int.tryParse(json['desconto']?.toString() ?? '0') ?? 0;
    final double precoBase =
        double.tryParse(json['preco']?.toString() ?? '0') ?? 0.0;
    final String clubeStr = (json['clube'] ?? 'Flamengo').toString();
    final String logoStr =
        (json['logoClube'] ?? obterLogoPadraoPorClube(clubeStr)).toString();

    if (tipo == 'promocao' || desconto > 0) {
      return ProdutoPromocao(
        id: json['id'].toString(),
        nome: (json['nome'] ?? 'Item de Futebol').toString(),
        categoria: (json['categoria'] ?? 'Camisas').toString(),
        clube: clubeStr,
        preco: precoBase,
        imagem: (json['imagem'] ?? logoStr).toString(),
        logoClube: logoStr,
        descricao: (json['descricao'] ??
                'Artigo oficial para partidas e treinos de futebol.')
            .toString(),
        percentualDesconto: desconto > 0 ? desconto : 15,
      );
    }

    return ProdutoOficial(
      id: json['id'].toString(),
      nome: (json['nome'] ?? 'Item de Futebol').toString(),
      categoria: (json['categoria'] ?? 'Camisas').toString(),
      clube: clubeStr,
      preco: precoBase,
      imagem: (json['imagem'] ?? logoStr).toString(),
      logoClube: logoStr,
      descricao: (json['descricao'] ??
              'Artigo oficial para partidas e treinos de futebol.')
          .toString(),
    );
  }
}

// Subclasse 1: Produto Oficial Regular
class ProdutoOficial extends ItemFutebol {
  ProdutoOficial({
    required super.id,
    required super.nome,
    required super.categoria,
    required super.clube,
    required super.preco,
    required super.imagem,
    super.logoClube,
    super.descricao,
  });

  @override
  String seloDestaque() => 'Oficial • $clube';
}

// Subclasse 2: Produto em Promoção de Dia de Jogo (sobrescreve cálculo de preço)
class ProdutoPromocao extends ItemFutebol {
  final int percentualDesconto;

  ProdutoPromocao({
    required super.id,
    required super.nome,
    required super.categoria,
    required super.clube,
    required super.preco,
    required super.imagem,
    super.logoClube,
    super.descricao,
    required this.percentualDesconto,
  });

  @override
  bool get emPromocao => true;

  @override
  double calcularPrecoFinal() {
    final fator = (100 - percentualDesconto).clamp(0, 100) / 100.0;
    return preco * fator;
  }

  @override
  String seloDestaque() => 'OFERTA -$percentualDesconto% OFF';

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['tipo'] = 'promocao';
    map['desconto'] = percentualDesconto;
    return map;
  }
}
