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
    final DateTime dataDoOcorrido,
    final String descricao,
    final List<String>? imagensAnexadas;
    final String usuarioNome,
    final String unidadeNome,
    final String? supervisorNome,
    final DateTime? dataDaAnalise


    Report({
        required this.id,
        required this.TipoDeIncidente,
        required this.StatusReport,
        required this.dataDoOcorrido,
        required this.descricao,
        this.imagensAnexadas,
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
        }
        StatusReport parseStatusReport(String? value){
            switch(value?.toUpperCase()){
                case 'PENDNTE':
                    return TipoDeIncidente.PENDNTE;
                case 'SOB_AVALIACAO':
                    return TipoDeIncidente.SOB_AVALIACAO;
                case 'NEGADO':
                    return TipoDeIncidente.NEGADO;
                case 'EM_TRATAMENTO':
                    return TipoDeIncidente.EM_TRATAMENTO;
                case 'TRATADO':
                    return TipoDeIncidente.TRATADO;
            }
        }

        return Report(

            id: json['Id'] ?? json['id'] ?? 0,

            tipoDeIncidente: parseTipoIncidente(json['TipoDeIncidente'] ?? json['tipoDeIncidente']),

            statusReport: parseStatusReport(json['StatusReport'] ?? json['statusReport']),


        )
    }
}