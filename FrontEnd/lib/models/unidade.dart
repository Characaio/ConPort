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

  // Vem no bloco "informacoes" do status geral.
  final String descricao;
  final String? imagem;

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

    this.descricao = '',
    this.imagem,

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
    // O status geral (GET /unidade/{id}) vem aninhado, em
    // informacoes/indicadores/dadosAmbientais; a rota antiga de
    // informacoes vem chapada. A tela usa os dois formatos, entao os
    // blocos sao abertos aqui antes de ler.
    final Map<String, dynamic> informacoes = _objeto(
      json['informacoes'] ?? json['Informacoes'],
    );
    final Map<String, dynamic> indicadores = _objeto(
      json['indicadores'] ?? json['Indicadores'],
    );
    final Map<String, dynamic> ambientais = _objeto(
      json['dadosAmbientais'] ?? json['DadosAmbientais'],
    );

    // Ordem de leitura: o bloco aninhado quando existe, o topo como reserva.
    dynamic campo(List<String> chaves) {
      for (final mapa in [informacoes, ambientais, indicadores, json]) {
        for (final chave in chaves) {
          final valor = mapa[chave];
          if (valor != null) return valor;
        }
      }
      return null;
    }

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
      id: parseInt(campo(['Id', 'id'])),

      nome: campo(['Nome', 'nome'])?.toString() ?? 'Unidade',

      localizacao:
          campo(['Localizacao', 'localizacao'])?.toString() ?? 'Não informado',

      bioma: campo(['Bioma', 'bioma'])?.toString() ?? 'Bioma',

      telefone: campo(['Telefone', 'telefone'])?.toString() ?? 'Telefone',

      descricao: campo(['Descricao', 'descricao'])?.toString() ?? '',

      imagem: campo(['Imagem', 'imagem'])?.toString(),

      horaDeAbertura: parseDate(campo(['HoraDeAbertura', 'horaDeAbertura'])),

      horaDeFechamento: parseDate(
        campo(['HoraDeFechamento', 'horaDeFechamento']),
      ),

      tipoDaUnidade: parseTipo(
        campo(['TipoDeUnidade', 'tipoDeUnidade'])?.toString(),
      ),

      areaTotal: parseDouble(campo(['AreaTotal', 'areaTotal'])),

      areaRegularizada: parseDouble(
        campo(['AreaRegularizada', 'areaRegularizada']),
      ),

      areaPreservada: parseDouble(
        campo(['AreaPreservada', 'areaPreservada']),
      ),

      areaMonitorada: parseDouble(
        campo(['AreaMonitorada', 'areaMonitorada']),
      ),

      areaBasePorCorredor: parseDouble(
        campo(['AreaBasePorCorredor', 'areaBasePorCorredor']),
      ),

      pontosMonitorados: parseInt(
        campo(['PontosMonitorados', 'pontosMonitorados']),
      ),

      pontosPrevistos: parseInt(
        campo(['PontosPrevistos', 'pontosPrevistos']),
      ),

      // O DTO de dados ambientais abrevia os nomes das especies e dos
      // corredores, entao as duas grafias sao lidas.
      quantidadeEspecies: parseInt(
        campo(['QuantidadeEspecies', 'quantidadeEspecies', 'quantEspecies']),
      ),

      quantidadeEspeciesEsperadas: parseInt(
        campo([
          'QuantidadeEspeciesEsperadas',
          'quantidadeEspeciesEsperadas',
          'quantEspeciesEsperadas',
        ]),
      ),

      qualidaAgua: parseDouble(
        campo(['QualidadeDaAgua', 'qualidadeDaAgua', 'QualidadeAgua', 'qualidadeAgua']),
      ),

      qualidadeSolo: parseDouble(
        campo(['QualidadeSolo', 'qualidadeSolo']),
      ),

      gestaoResiduos: parseDouble(
        campo(['GestaoResiduos', 'gestaoResiduos']),
      ),

      quantReports: parseNullableInt(campo(['QuantReports', 'quantReports'])),

      integridadeTerritorial: parseNullableDouble(
        campo(['IntegridadeTerritorial', 'integridadeTerritorial']),
      ),

      corredoresNecessarios: parseNullableInt(
        campo(['CorredoresNecessarios', 'corredoresNecessarios']),
      ),

      conectividadeEcologica: parseNullableDouble(
        campo(['ConectividadeEcologica', 'conectividadeEcologica']),
      ),

      qualidadeAmbiental: parseNullableDouble(
        campo(['QualidadeAmbiental', 'qualidadeAmbiental']),
      ),

      preservacaoLocal: parseNullableDouble(
        campo(['PreservacaoLocal', 'preservacaoLocal']),
      ),

      fiscalizaocao: parseNullableDouble(
        campo(['Fiscalizacao', 'fiscalizacao']),
      ),

      biodiversidade: parseNullableDouble(
        campo(['Biodiversidade', 'biodiversidade']),
      ),

      fiscalizacaoEmString: doubleParaString(
        parseNullableDouble(campo(['Fiscalizacao', 'fiscalizacao'])),
      ),

      biodiversidadeEmString: doubleParaString(
        parseNullableDouble(campo(['Biodiversidade', 'biodiversidade'])),
      ),

      corredoresExistentes: parseNullableInt(
        campo(['QuantCorredores', 'quantCorredores', 'CorredoresExistentes']),
      ),
    );
  }
}

/// Abre um bloco aninhado do status geral; devolve mapa vazio se não vier.
Map<String, dynamic> _objeto(dynamic valor) {
  if (valor is Map<String, dynamic>) return valor;
  if (valor is Map) return valor.map((k, v) => MapEntry('$k', v));

  return <String, dynamic>{};
}
