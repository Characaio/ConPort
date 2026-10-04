/// Anúncio da unidade de conservação.
///
/// Vem de `GET /unidade/{id}/aviso?limite=N` ([AvisoResponseDTO]). O DTO
/// escreve o título como `Titutlo`; a leitura aceita essa grafia, a correta
/// e a minúscula, para não depender do typo do backend.
class Aviso {
  final int id;
  final String titulo;
  final String texto;
  final DateTime data;

  /// Aparece no topo da lista, com o ícone de alfinete.
  final bool fixado;

  /// URL da foto do anúncio; sem ela o card aparece sem imagem.
  final String? imagem;

  const Aviso({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.data,
    this.fixado = false,
    this.imagem,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    String? texto(List<String> chaves) {
      for (final chave in chaves) {
        final valor = json[chave];
        if (valor != null) return valor.toString();
      }

      return null;
    }

    final data = texto(['HorarioDoAviso', 'horarioDoAviso', 'Data', 'data']);

    return Aviso(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      titulo: texto(['Titutlo', 'Titulo', 'titulo', 'TituloAviso']) ?? '',
      texto: texto(['Descricao', 'descricao', 'Conteudo', 'conteudo']) ?? '',
      data: DateTime.tryParse(data ?? '') ?? DateTime.now(),
      // Aviso antigo, criado antes do campo existir, não é fixado.
      fixado: (json['Fixo'] ?? json['fixo']) == true,
      imagem: texto(['Imagem', 'imagem']),
    );
  }
}