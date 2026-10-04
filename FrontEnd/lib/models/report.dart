import 'package:conport/models/report_lista.dart';

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
        // Os DTOs do backend nomeiam o tipo e o status como "Tipo"/"Status"
        // (não "TipoDeIncidente"/"StatusReport"), e a localização vem separada
        // em Latitude/Longitude, sem um campo "Localizacao". Ler só a grafia
        // antiga fazia o POST do report — que responde 201 e grava tudo —
        // estourar exceção ao ler a resposta: o report era criado, mas a tela
        // mostrava erro em vez de ir para a lista.
        String? texto(List<String> chaves){
            for (final chave in chaves){
                final valor = json[chave];
                if (valor != null) return valor.toString();
            }
            return null;
        }

        final latitude = texto(['Latitude','latitude']);
        final longitude = texto(['Longitude','longitude']);

        final anexos = json['ImagensAnexadas'] ?? json['imagensAnexadas'];
        final dataDaAnalise = texto(['DataDaAnalise','dataDaAnalise']);

        return Report(
            id: (json['Id'] ?? json['id'] ?? 0) as int,

            tipoDeIncidente: ReportParser.tipo(
                texto(['Tipo','tipo','TipoDeIncidente','tipoDeIncidente'])),

            statusReport: ReportParser.status(
                texto(['Status','status','StatusReport','statusReport'])),

            dataDoOcorrido: ReportParser.data(
                json['DataDoOcorrido'] ?? json['dataDoOcorrido']),

            descricao: texto(['Descricao','descricao']) ?? '',

            localizacao: texto(['Localizacao','localizacao']) ??
                (latitude != null && longitude != null
                    ? '$latitude, $longitude'
                    : 'Local não informado'),

            imagensAnexadas: anexos is List
                ? anexos.map((e) => e.toString()).toList()
                : null,

            usuarioId: (json['UsuarioId'] ?? json['usuarioId'] ?? 0) as int,

            unidadeId: (json['UnidadeId'] ?? json['unidadeId'] ?? 0) as int,

            usuarioNome: texto(['UsuarioNome','usuarioNome']) ?? '',

            unidadeNome: texto(['UnidadeNome','unidadeNome']) ?? '',

            supervisorNome: texto(['SupervisorNome','supervisorNome']),

            dataDaAnalise: dataDaAnalise != null
                ? ReportParser.data(dataDaAnalise)
                : null,
        );
    }
}