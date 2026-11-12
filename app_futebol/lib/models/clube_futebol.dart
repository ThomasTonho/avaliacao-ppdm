import 'package:app_futebol/models/item_futebol.dart';

class ClubeFutebol {
  final String id;
  final String nome;
  final String estadio;
  final String anoFundacao;
  final String pais;
  final String escudo;
  final String uniforme;

  ClubeFutebol({
    required this.id,
    required this.nome,
    required this.estadio,
    required this.anoFundacao,
    required this.pais,
    required this.escudo,
    this.uniforme = '',
  });

  String get urlEscudoSegura => normalizarUrlImagem(escudo);
  String get urlUniformeSegura => normalizarUrlImagem(uniforme);

  factory ClubeFutebol.fromJson(Map<String, dynamic> json) {
    return ClubeFutebol(
      id: (json['id'] ?? json['idTeam'] ?? '').toString(),
      nome: (json['nome'] ?? json['strTeam'] ?? 'Clube').toString(),
      estadio: (json['estadio'] ?? json['strStadium'] ?? 'Estádio Principal')
          .toString(),
      anoFundacao: (json['anoFundacao'] ?? json['intFormedYear'] ?? 'N/D')
          .toString(),
      pais: (json['pais'] ?? json['strCountry'] ?? 'Brasil').toString(),
      escudo: (json['escudo'] ?? json['strBadge'] ?? json['strLogo'] ?? '')
          .toString(),
      uniforme:
          (json['uniforme'] ?? json['strEquipment'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'estadio': estadio,
      'anoFundacao': anoFundacao,
      'pais': pais,
      'escudo': escudo,
      'uniforme': uniforme,
    };
  }
}
