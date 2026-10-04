import 'package:conport/models/report.dart';

/// Report como aparece na lista do usuário.
///
/// O backend devolve [ReportListaDTO], que traz o que o card mostra: tipo,
/// status, quando aconteceu, onde, e os dados da análise quando ela existe.
class ReportLista {
  final int id;
  final int unidadeId;
  final String unidadeNome;
  final int usuarioId;
  final String usuarioNome;
  final TipoDeIncidente tipo;
  final StatusReport status;
  final String? prioridade;
  final DateTime dataDoOcorrido;
  final String descricao;
  final double? latitude;
  final double? longitude;
  final int quantidadeAnexos;
  final String? supervisorNome;
  final DateTime? dataDaAnalise;
  final String? motivoDaNegacao;

  const ReportLista({
    required this.id,
    required this.unidadeId,
    required this.unidadeNome,
    required this.usuarioId,
    required this.usuarioNome,
    required this.tipo,
    required this.status,
    this.prioridade,
    required this.dataDoOcorrido,
    required this.descricao,
    this.latitude,
    this.longitude,
    required this.quantidadeAnexos,
    this.supervisorNome,
    this.dataDaAnalise,
    this.motivoDaNegacao,
  });

  factory ReportLista.fromJson(Map<String, dynamic> json) {
    return ReportLista(
      id: json['Id'] ?? json['id'] ?? 0,
      unidadeId: json['UnidadeId'] ?? json['unidadeId'] ?? 0,
      unidadeNome: json['UnidadeNome'] ?? json['unidadeNome'] ?? '',
      usuarioId: json['UsuarioId'] ?? json['usuarioId'] ?? 0,
      usuarioNome: json['UsuarioNome'] ?? json['usuarioNome'] ?? '',
      tipo: ReportParser.tipo(json['Tipo'] ?? json['tipo']),
      status: ReportParser.status(json['Status'] ?? json['status']),
      prioridade: (json['Prioridade'] ?? json['prioridade'])?.toString(),
      dataDoOcorrido: ReportParser.data(
        json['DataDoOcorrido'] ?? json['dataDoOcorrido'],
      ),
      descricao: json['Descricao'] ?? json['descricao'] ?? '',
      latitude: (json['Latitude'] ?? json['latitude'])?.toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'])?.toDouble(),
      quantidadeAnexos:
          json['QuantidadeAnexos'] ?? json['quantidadeAnexos'] ?? 0,
      supervisorNome: json['SupervisorNome'] ?? json['supervisorNome'],
      dataDaAnalise: (json['DataDaAnalise'] != null ||
              json['dataDaAnalise'] != null)
          ? ReportParser.data(json['DataDaAnalise'] ?? json['dataDaAnalise'])
          : null,
      motivoDaNegacao: json['MotivoDaNegacao'] ?? json['motivoDaNegacao'],
    );
  }

  /// Texto curto de onde aconteceu, para o card.
  String get localizacao {
    if (unidadeNome.isNotEmpty) return unidadeNome;

    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }

    return 'Local não informado';
  }
}

/// Conversores compartilhados com o [Report] antigo.
///
/// O enum do frontend chama o pendente de PENDNTE (typo do backend), então a
/// leitura tolera as duas grafias.
class ReportParser {
  static TipoDeIncidente tipo(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'QUEIMADA':
        return TipoDeIncidente.QUEIMADA;
      case 'ANIMAL_FERIDO':
        return TipoDeIncidente.ANIMAL_FERIDO;
      case 'ANIMAL_EXOTICO':
        return TipoDeIncidente.ANIMAL_EXOTICO;
      case 'POLUICAO':
      case 'POLUIÇÃO':
        return TipoDeIncidente.POLUICAO;
      case 'DESMATAMENTO':
        return TipoDeIncidente.DESMATAMENTO;
    }
    throw FormatException('Tipo de incidente inválido: $value');
  }

  static StatusReport status(dynamic value) {
    switch (value?.toString().toUpperCase()) {
      case 'PENDENTE':
      case 'PENDNTE':
        return StatusReport.PENDNTE;
      case 'SOB_AVALIACAO':
      case 'SOB_AVALIAÇÃO':
        return StatusReport.SOB_AVALIACAO;
      case 'NEGADO':
        return StatusReport.NEGADO;
      case 'EM_TRATAMENTO':
        return StatusReport.EM_TRATAMENTO;
      // O backend tem ACEITO e TRATADO como status separados, mas o app
      // trata os dois como "concluído": ficam na aba Tratados.
      case 'ACEITO':
      case 'TRATADO':
        return StatusReport.TRATADO;
    }
    throw FormatException('Status de report inválido: $value');
  }

  static DateTime data(dynamic value) {
    if (value == null) {
      throw const FormatException('Data não informada');
    }

    final data = DateTime.tryParse(value.toString());

    if (data == null) {
      throw FormatException('Data inválida: $value');
    }

    return data;
  }
}