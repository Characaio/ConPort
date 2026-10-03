import 'package:conport/models/report.dart';

class ReportMock {
  static List<Report> buscarReportsDaUnidade(int unidadeId) {
    return [
      Report(
        id: 1,
        tipoDeIncidente: TipoDeIncidente.ANIMAL_FERIDO,
        statusReport: StatusReport.SOB_AVALIACAO,
        dataDoOcorrido: DateTime(2025, 9, 18, 10, 30),
        descricao: 'Animal ferido próximo à trilha principal.',
        localizacao: 'Trilha principal',
        usuarioId: 2,
        unidadeId: unidadeId,
        usuarioNome: 'Usuário Demo',
        unidadeNome: 'Parque Estadual de Exemplo',
      ),
      Report(
        id: 2,
        tipoDeIncidente: TipoDeIncidente.DESMATAMENTO,
        statusReport: StatusReport.EM_TRATAMENTO,
        dataDoOcorrido: DateTime(2025, 9, 12, 14, 15),
        descricao: 'Área com sinais recentes de desmatamento.',
        localizacao: 'Setor norte',
        usuarioId: 2,
        unidadeId: unidadeId,
        usuarioNome: 'Usuário Demo',
        unidadeNome: 'Parque Estadual de Exemplo',
        supervisorNome: 'Equipe de fiscalização',
      ),
      Report(
        id: 3,
        tipoDeIncidente: TipoDeIncidente.POLUICAO,
        statusReport: StatusReport.TRATADO,
        dataDoOcorrido: DateTime(2025, 8, 30, 8, 45),
        descricao: 'Resíduos encontrados próximos ao córrego.',
        localizacao: 'Córrego das Palmeiras',
        usuarioId: 2,
        unidadeId: unidadeId,
        usuarioNome: 'Usuário Demo',
        unidadeNome: 'Parque Estadual de Exemplo',
        supervisorNome: 'Equipe de fiscalização',
        dataDaAnalise: DateTime(2025, 9, 2),
      ),
    ];
  }
}
