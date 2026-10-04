/// Uma notificação do usuário.
///
/// Veio do model que estava embutido em `widgets/notifications.dart` (mesmos
/// campos: id, titulo, texto, data, lida) e ganhou o que a API precisa.
///
/// `usuarioId` é novo: o controller guarda a lista em memória e, sem esse
/// campo, uma notificação que sobrasse de outra conta continuaria aparecendo
/// depois do logout.
class Notificacao {
  final int id;
  final int usuarioId;
  final String titulo;
  final String texto;
  final DateTime data;
  final bool lida;

  const Notificacao({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.data,
    this.usuarioId = 0,
    this.lida = false,
  });

  /// Lê o JSON do `GET /usuarios/{id}/notificacoes`.
  ///
  /// O backend responde em camelCase (id, titulo, texto, data, lida), igual
  /// aos nomes daqui. As duas grafias de cada campo são aceitas para o app
  /// não quebrar se o backend voltar com PascalCase, como acontece em outros
  /// recursos da API.
  factory Notificacao.fromJson(Map<String, dynamic> json) {
    DateTime lerData(dynamic valor) {
      if (valor == null) return DateTime.now();

      return DateTime.tryParse(valor.toString()) ?? DateTime.now();
    }

    return Notificacao(
      id: _lerInteiro(json['id'] ?? json['Id']),
      usuarioId: _lerInteiro(json['usuarioId'] ?? json['UsuarioId']),
      titulo: (json['titulo'] ?? json['Titulo'] ?? '').toString(),
      texto: (json['texto'] ?? json['Texto'] ?? '').toString(),
      data: lerData(json['data'] ?? json['Data']),
      lida: _lerBooleano(json['lida'] ?? json['Lida']),
    );
  }

  Notificacao copyWith({bool? lida}) {
    return Notificacao(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo,
      texto: texto,
      data: data,
      lida: lida ?? this.lida,
    );
  }

  /// True quando ainda não foi lida — o que pinta o bolinha vermelha.
  bool get naoLida => !lida;
}

int _lerInteiro(dynamic valor) {
  if (valor is int) return valor;
  if (valor is num) return valor.toInt();

  return int.tryParse(valor?.toString() ?? '') ?? 0;
}

bool _lerBooleano(dynamic valor) {
  if (valor is bool) return valor;
  if (valor is num) return valor != 0;

  final texto = valor?.toString().toLowerCase();

  return texto == 'true' || texto == '1';
}
