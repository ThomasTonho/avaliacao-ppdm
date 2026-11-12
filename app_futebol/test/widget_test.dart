import 'package:flutter_test/flutter_test.dart';
import 'package:app_futebol/models/item_futebol.dart';

void main() {
  test('Subclasses ProdutoOficial e ProdutoPromocao calculam preco final', () {
    final regular = ItemFutebol.fromJson({
      'id': '1',
      'nome': 'Chuteira Campo',
      'categoria': 'Chuteiras',
      'clube': 'Pro',
      'tipo': 'regular',
      'desconto': 0,
      'preco': 300.0,
      'imagem': 'https://example.com/img.png',
    });

    final promo = ItemFutebol.fromJson({
      'id': '2',
      'nome': 'Camisa Seleção',
      'categoria': 'Camisas',
      'clube': 'Brasil',
      'tipo': 'promocao',
      'desconto': 20,
      'preco': 350.0,
      'imagem': 'https://example.com/img.png',
    });

    expect(regular, isA<ProdutoOficial>());
    expect(regular.calcularPrecoFinal(), 300.0);
    expect(regular.seloDestaque(), 'Oficial • Pro');

    expect(promo, isA<ProdutoPromocao>());
    expect(promo.calcularPrecoFinal(), 280.0);
    expect(promo.seloDestaque(), 'OFERTA -20% OFF');
  });

  test('Serializacao toJson e desserializacao fromJson da API JSON', () {
    final original = ItemFutebol.fromJson({
      'id': '99',
      'nome': 'Camisa PSG Home',
      'categoria': 'Camisas',
      'clube': 'PSG',
      'tipo': 'promocao',
      'desconto': 10,
      'preco': 400.0,
      'imagem': 'https://example.com/psg.png',
      'descricao': 'Camisa oficial versão torcedor',
    });

    final json = original.toJson();
    expect(json['id'], '99');
    expect(json['nome'], 'Camisa PSG Home');
    expect(json['tipo'], 'promocao');
    expect(json['desconto'], 10);
    expect(json['preco'], 400.0);

    final reconstruido = ItemFutebol.fromJson(json);
    expect(reconstruido.id, '99');
    expect(reconstruido.emPromocao, isTrue);
    expect(reconstruido.calcularPrecoFinal(), 360.0);
  });
}
