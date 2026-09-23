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

  final String? horaDeAbertura;
  final String? horaDeFechamento;

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

  final int? corredoresExistentes;
  final int? quantReports;
  final double? integridadeTerritorial;
  final int? corredoresNecessarios;
  final double? conectividadeEcologica;
  final double? qualidadeAmbiental;
  final double? preservacaoLocal;
  final double? fiscalizaocao;
  final double? biodiversidade;
  final String? fiscalizacaoEmString;
  final String? biodiversidadeEmString;

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


    this.corredoresExistentes,
    this.quantReports,
    this.integridadeTerritorial,
    this.corredoresNecessarios,
    this.conectividadeEcologica,
    this.qualidadeAmbiental,
    this.preservacaoLocal,
    this.fiscalizaocao,
    this.biodiversidade,
    this.fiscalizacaoEmString,
    this.biodiversidadeEmString
  });

  factory Unidade.fromJson(Map<String, dynamic> json) {
    TipoDeUnidade parseTipo(String? value) {
      switch (value?.toUpperCase()) {
        case 'PARQUE_NACIONAL':
          return TipoDeUnidade.PARQUE_NACIONAL;

        case 'RESERVA_BIOLOGICA':
          return TipoDeUnidade.RESERVA_BIOLOGICA;

        case 'MONUMENTO_NATURAL':
          return TipoDeUnidade.MONUMENTO_NATURAL;

        case 'FLONA':
          return TipoDeUnidade.FLONA;
        case 'RESERVA_EXTRATIVISTA':
          return TipoDeUnidade.RESERVA_EXTRATIVISTA;

        case 'RPPN':
          return TipoDeUnidade.RPPN;

        default:
          return TipoDeUnidade.DESCONHECIDO;
      }
    }

    String? parseDate(dynamic value) {
      if (value == null) return null;
      final time = value.toString();
      return time.substring(0,5);
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
    

    String? doubleParaString(double? porcentagem){
      if (porcentagem == null) return null;
      if (porcentagem >= 0 && porcentagem <= 33.3){
        return "Baixo";
      } else if (porcentagem > 33.3 && porcentagem <= 66.6){
        return "Medio";
      } else if (porcentagem > 66.6 && porcentagem <=100){
        return "Alto";
      }
      return "Indefinido";
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

      tipoDaUnidade: parseTipo(json['TipoDeUnidade'] ?? json['tipoDeUnidade']),

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
      fiscalizacaoEmString: doubleParaString(parseNullableDouble(
        json['Fiscalizacao'] ?? json['fiscalizacao'],
      )),
      biodiversidadeEmString: doubleParaString(parseNullableDouble(
        json['Biodiversidade'] ?? json['biodiversidade'],
      )),
      corredoresExistentes: parseNullableInt(
        json["CorredoresNecessarios"] ?? json["corredoresNecessarios"]
      )
    );



  }
}
