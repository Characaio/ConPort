enum TipoDeIncidente {
    QUEIMADA,
    ANIMAL_FERIDO,
    ANIMAL_EXOTICO,
    POLUICAO,
    DESMATAMENTO
}
enum StatusReport {
    PENDNTE,
    SOB_AVALIACAO,
    NEGADO,
    EM_TRATAMENTO,
    TRATADO
}

class Report{
    final int id;
    final TipoDeIncidente tipoDeIncidente;
    final StatusReport statusReport;
    final DateTime dataDoOcorrido;
    final String descricao;
    final String localizacao;
    final List<String>? imagensAnexadas;
    final int usuarioId;
    final int unidadeId;
    final String usuarioNome;
    final String unidadeNome;
    final String? supervisorNome;
    final DateTime? dataDaAnalise;

    Report({
        required this.id,
        required this.tipoDeIncidente,
        required this.statusReport,
        required this.dataDoOcorrido,
        required this.descricao,
        required this.localizacao,
        this.imagensAnexadas,
        required this.usuarioId,
        required this.unidadeId,
        required this.usuarioNome,
        required this.unidadeNome,
        this.supervisorNome,
        this.dataDaAnalise,
    });

    factory Report.fromJson(Map<String,dynamic> json){
        TipoDeIncidente parseTipoIncidente(String? value){
            switch(value?.toUpperCase()){
                case 'QUEIMADA':
                    return TipoDeIncidente.QUEIMADA;
                case 'ANIMAL_FERIDO':
                    return TipoDeIncidente.ANIMAL_FERIDO;
                case 'ANIMAL_EXOTICO':
                    return TipoDeIncidente.ANIMAL_EXOTICO;
                case 'POLUICAO':
                    return TipoDeIncidente.POLUICAO;
                case 'DESMATAMENTO':
                    return TipoDeIncidente.DESMATAMENTO;
            }
            throw Exception("Alguma merda rolou rapaz");
        }
        StatusReport parseStatusReport(String? value){
            switch(value?.toUpperCase()){
                case 'PENDNTE':
                    return StatusReport.PENDNTE;
                case 'SOB_AVALIACAO':
                    return StatusReport.SOB_AVALIACAO;
                case 'NEGADO':
                    return StatusReport.NEGADO;
                case 'EM_TRATAMENTO':
                    return StatusReport.EM_TRATAMENTO;
                case 'TRATADO':
                    return StatusReport.TRATADO;
            }
            throw Exception("Alguma merda rolou rapaz");
        }
        DateTime parseDate(dynamic value) {
          if (value == null) {
            throw FormatException('Data não informada');
          }

          final data = DateTime.tryParse(value.toString());

          if (data == null) {
            throw FormatException('Data inválida: $value');
          }

          return data;
        }
        return Report(

            id: json['Id'] ?? json['id'] ?? 0,

            tipoDeIncidente: parseTipoIncidente(json['TipoDeIncidente'] ?? json['tipoDeIncidente']),

            statusReport: parseStatusReport(json['StatusReport'] ?? json['statusReport']),

            dataDoOcorrido: parseDate(json['DataDoOcorrido'] ?? json['dataDoOcorrido']),
            
            descricao: json['Descricao'] ?? json['descricao'] ?? "vazio games",

            localizacao: json['Localizacao'] ?? json['localizacao'] ?? "fames",

            imagensAnexadas: json['ImagensAnexadas'] ?? json['imagensAnexadas'] ?? "null",

            usuarioId: json["UsuarioId"] ?? json["usuarioId"] ?? 0,

            unidadeId: json["UnidadeId"] ?? json["unidadeId"] ?? 0,

            usuarioNome: json["UsuarioNome"] ?? json["usuarioNome"] ?? "null",

            unidadeNome: json["UnidadeNome"] ?? json["unidadeNome"] ?? "null",

            supervisorNome: json["SupervisorNome"] ?? json["supervisorNome"] ?? "null",

            dataDaAnalise:
                  json["DataDaAnalise"] != null || json["dataDaAnalise"] != null
                   ? parseDate(json["DataDaAnalise"] ?? json["dataDaAnalise"])
                    : null,
                     );
    }
}