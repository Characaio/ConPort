enum TipoDeUnidade {
  PARQUE_NACIONAL,
  RESERVA_BIOLOGICA,
  MONUMENTO_NATURAL,

  FLONA,
  RESERVA_EXTRATIVISTA,
  RPPN,

  DESCONHECIDO,
}

class Unidade {
  final int id;
  final String nome;
  final String localizacao;
  final String bioma;
  final String telefone;

  final DateTime? horaDeAbertura;
  final DateTime? horaDeFechamento;

  final TipoDeUnidade tipoDaUnidade;

  final double areaTotal;
  final double areaRegularizada;
  final double areaPreservada;
  final double areaMonitorada;
  final double areaBasePorCorredor;

  final int pontosMonitorados;
  final int pontosPrevistos;
  final int quantidadeEspecies;
  final int quantidadeEspeciesEsperadas;

  final double qualidaAgua;
  final double qualidadeSolo;
  final double gestaoResiduos;

  final int? quantReports;
  final double? integridadeTerritorial;
  final int? corredoresNecessarios;
  final double? conectividadeEcologica;
  final double? qualidadeAmbiental;
  final double? preservacaoLocal;
  final double? fiscalizaocao;
  final double? biodiversidade;

  const Unidade({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.bioma,
    required this.telefone,

    required this.horaDeAbertura,
    required this.horaDeFechamento,

    required this.tipoDaUnidade,

    required this.areaTotal,
    required this.areaRegularizada,
    required this.areaPreservada,
    required this.areaMonitorada,
    required this.areaBasePorCorredor,

    required this.pontosMonitorados,
    required this.pontosPrevistos,
    required this.quantidadeEspecies,
    required this.quantidadeEspeciesEsperadas,

    required this.qualidaAgua,
    required this.qualidadeSolo,
    required this.gestaoResiduos,

    this.quantReports,
    this.integridadeTerritorial,
    this.corredoresNecessarios,
    this.conectividadeEcologica,
    this.qualidadeAmbiental,
    this.preservacaoLocal,
    this.fiscalizaocao,
    this.biodiversidade,
  });

  factory Unidade.fromJson(Map<String, dynamic> json) {
    TipoDeUnidade parseTipo(String? value) {
      switch (value?.toUpperCase()) {
        case 'PARQUE NACIONAL':
          return TipoDeUnidade.PARQUE_NACIONAL;

        case 'RESERVA BIOLOGICA':
          return TipoDeUnidade.RESERVA_BIOLOGICA;

        case 'MONUMENTO NATURAL':
          return TipoDeUnidade.MONUMENTO_NATURAL;

        case 'FLONA':
          return TipoDeUnidade.FLONA;

        case 'RESERVA_EXTRATIVISTA':
        case 'RESERVA EXTRATIVISTA':
          return TipoDeUnidade.RESERVA_EXTRATIVISTA;

        case 'RPPN':
          return TipoDeUnidade.RPPN;

        default:
          return TipoDeUnidade.DESCONHECIDO;
      }
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }

      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value is String) {
        return int.tryParse(value) ?? 0;
      }

      return 0;
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.'));
      }

      return null;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value is String) {
        return int.tryParse(value);
      }

      return null;
    }

    return Unidade(
      id: parseInt(json['Id'] ?? json['id']),

      nome: json['Nome'] ?? json['nome'] ?? 'Unidade',

      localizacao: json['Localizacao'] ?? json['localizacao'] ?? 'NULL',

      bioma: json['Bioma'] ?? json['bioma'] ?? 'Bioma',

      telefone: json['Telefone'] ?? json['telefone'] ?? 'Telefone',

      horaDeAbertura: parseDate(
        json['HoraDeAbertura'] ?? json['horaDeAbertura'],
      ),

      horaDeFechamento: parseDate(
        json['HoraDeFechamento'] ?? json['horaDeFechamento'],
      ),

      tipoDaUnidade: parseTipo(json['TipoDaUnidade'] ?? json['tipoDaUnidade']),

      areaTotal: parseDouble(json['AreaTotal'] ?? json['areaTotal']),

      areaRegularizada: parseDouble(
        json['AreaRegularizada'] ?? json['areaRegularizada'],
      ),

      areaPreservada: parseDouble(
        json['AreaPreservada'] ?? json['areaPreservada'],
      ),

      areaMonitorada: parseDouble(
        json['AreaMonitorada'] ?? json['areaMonitorada'],
      ),

      areaBasePorCorredor: parseDouble(
        json['AreaBasePorCorredor'] ?? json['areaBasePorCorredor'],
      ),

      pontosMonitorados: parseInt(
        json['PontosMonitorados'] ?? json['pontosMonitorados'],
      ),

      pontosPrevistos: parseInt(
        json['PontosPrevistos'] ?? json['pontosPrevistos'],
      ),

      quantidadeEspecies: parseInt(
        json['QuantidadeEspecies'] ?? json['quantidadeEspecies'],
      ),

      quantidadeEspeciesEsperadas: parseInt(
        json['QuantidadeEspeciesEsperadas'] ??
            json['quantidadeEspeciesEsperadas'],
      ),

      qualidaAgua: parseDouble(
        json['QualidadeDaAgua'] ?? json['qualidadeDaAgua'],
      ),

      qualidadeSolo: parseDouble(
        json['QualidadeSolo'] ?? json['qualidadeSolo'],
      ),

      gestaoResiduos: parseDouble(
        json['GestaoResiduos'] ?? json['gestaoResiduos'],
      ),

      quantReports: parseNullableInt(
        json['QuantReports'] ?? json['quantReports'],
      ),

      integridadeTerritorial: parseNullableDouble(
        json['IntegridadeTerritorial'] ?? json['integridadeTerritorial'],
      ),

      corredoresNecessarios: parseNullableInt(
        json['CorredoresNecessarios'] ?? json['corredoresNecessarios'],
      ),

      conectividadeEcologica: parseNullableDouble(
        json['ConectividadeEcologica'] ?? json['conectividadeEcologica'],
      ),

      qualidadeAmbiental: parseNullableDouble(
        json['QualidadeAmbiental'] ?? json['qualidadeAmbiental'],
      ),

      preservacaoLocal: parseNullableDouble(
        json['PreservacaoLocal'] ?? json['preservacaoLocal'],
      ),

      fiscalizaocao: parseNullableDouble(
        json['Fiscalizacao'] ?? json['fiscalizacao'],
      ),

      biodiversidade: parseNullableDouble(
        json['Biodiversidade'] ?? json['biodiversidade'],
      ),
    );
  }
}
