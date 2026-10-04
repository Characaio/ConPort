/// Fauna ou flora: é o que separa as duas grades da tela de ecossistema.
enum TipoEspecie { fauna, flora }

/// Espécie registrada na unidade.
///
/// Vem de `GET /unidade/{id}/especies?tipo=FAUNA|FLORA` ([EspecieDTO]).
class Especie {
  final int id;
  final String nome;
  final String? nomeCientifico;
  final String? descricao;
  final String? imagem;
  final TipoEspecie tipo;

  const Especie({
    required this.id,
    required this.nome,
    this.nomeCientifico,
    this.descricao,
    this.imagem,
    this.tipo = TipoEspecie.fauna,
  });

  factory Especie.fromJson(Map<String, dynamic> json) {
    String? texto(List<String> chaves) {
      for (final chave in chaves) {
        final valor = json[chave];
        if (valor != null) return valor.toString();
      }

      return null;
    }

    final tipo = texto(['Tipo', 'tipo'])?.toUpperCase();

    return Especie(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      nome: texto(['Nome', 'nome']) ?? '',
      nomeCientifico: texto(['NomeCientifico', 'nomeCientifico']),
      descricao: texto(['Descricao', 'descricao']),
      imagem: texto(['Imagem', 'imagem']),
      tipo: tipo == 'FLORA' ? TipoEspecie.flora : TipoEspecie.fauna,
    );
  }
}