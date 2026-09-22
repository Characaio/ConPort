
enum TipoDeUnidade {
   PARQUE_NACIONAL,
   RESERVA_BIOLOGICA,
   MONUMENTO_NATURAL,

   FLONA,
   RESERVA_EXTRATIVISTA,
   RPPN,

   DESCONHECIDO
}

class Unidade{
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

    this.integridadeTerritorial,
    this.corredoresNecessarios,
    this.conectividadeEcologica,
    this.qualidadeAmbiental,
    this.preservacaoLocal,
    this.fiscalizaocao,
    this.biodiversidade,
        
    });

    factory Unidade.fromJson(Map<String,dynamic> json){
        TipoDeUnidade parseTipo(String? value){
            switch (value?.toUpperCase()){
                case 'PARQUE NACIONAL':
                    return TipoDeUnidade.PARQUE_NACIONAL;
                case 'RESERVA BIOLOGICA':
                    return TipoDeUnidade.RESERVA_BIOLOGICA;
                case 'MONUMENTO NATURAL':
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

        DateTime? parseDate(dynamic value) {
            if (value == null) return null;
            return DateTime.tryParse(value.toString());
        }


        return Unidade(
            id:json ['Id'] ?? json ['id'] ?? 0,

            nome: json['Nome'] ?? json['nome'] ?? 'Unidade',

            localizacao: json['Localizacao'] ?? json['localizacao'] ?? 'NULL',

            bioma: json['Bioma'] ?? json['bioma'] ?? 'Bioma',

            telefone: json['Telefone'] ?? json['telefone'] ?? 'Telefone',

            horaDeAbertura: parseDate(json['HoraDeAbertura'] ?? json['horaDeAbertura']),

            tipoDaUnidade: parseTipo(json['TipoDaUnidade'] ?? json['tipoDaUnidade']),

            horaDeFechamento: parseDate(json['HoraDeFechamento'] ?? json['horaDeFechamento']),

            areaTotal: json['AreaTotal'] ?? json['areaTotal'] ?? 'Area Total',

            areaRegularizada: json['AreaRegularizada'] ?? json['areaRegularizada'] ?? 'Area Regularizada',

            areaPreservada: json['AreaPreservada'] ?? json['areaPreservada'] ?? 'Area preservada',

            areaMonitorada: json['AreaMonitorada'] ?? json['areaMonitorada'] ?? 'Area Monitorada',

            areaBasePorCorredor: json['AreaBasePorCorredor'] ?? json['areaBasePorCorredor'] ?? 'Area Base Por Corredor', 

            pontosMonitorados: json['PontosMonitorados'] ?? json['pontosMonitorados'] ?? 'Pontos Monitorados',

            pontosPrevistos: json['PontosPrevistos'] ?? json['pontosPrevistos'] ?? 'Pontos Previstos',

            quantidadeEspecies: json['QuantidadeEspecies'] ?? json['quantidadeEspecies'] ?? 'Quantidade Especies',

            quantidadeEspeciesEsperadas: json['QuantidadeEspeciesEsperadas'] ?? json['quantidadeEspeciesEsperadas'] ?? 'Quantidade Especies Esperadas',

            qualidaAgua: json['QualidadeDaAgua'] ?? json['qualidadeDaAgua'] ?? 'Qualidade Da Agua',

            qualidadeSolo: json['QualidadeSolo'] ?? json['qualidadeSolo'] ?? 'Qualidade Solo',

            gestaoResiduos: json['GestaoResiduos'] ?? json['gestaoResiduos'] ?? 'Gestao Residuos',

            integridadeTerritorial: json['IntegridadeTerritorial'] ?? json['integridadeTerritorial'] ?? 'Integridade Territorial',

            corredoresNecessarios: json['CorredoresNecessarios'] ?? json['corredoresNecessarios'] ?? 'Corredores Necessarios',

            conectividadeEcologica: json['ConectividadeEcologica'] ?? json['conectividadeEcologica'] ?? 'Conectividade Ecologica',

            qualidadeAmbiental: json['QualidadeAmbiental'] ?? json['qualidadeAmbiental'] ?? 'Qualidade Ambiental',

            preservacaoLocal: json['PreservacaoLocal'] ?? json['preservacaoLocal'] ?? 'Preservacao Local',

            fiscalizaocao: json['Fiscalizacao'] ?? json['fiscalizacao'] ?? 'Fiscalizacao',

            biodiversidade: json['Biodiversidade'] ?? json['biodiversidade'] ?? 'Biodiversidade'
        );
    }
}
