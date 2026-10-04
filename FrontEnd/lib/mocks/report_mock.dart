import 'package:conport/models/report.dart';
import 'package:conport/models/report_lista.dart';

class ReportMock {
  /// Report criado no modo mockado: nasce "pendente", igual ao que o
  /// backend faria antes da análise de um supervisor.
  static Report postarReport({
    required int unidadeId,
    required int usuarioId,
    required String tipo,
    required String descricao,
    required DateTime dataDoOcorrido,
  }) {
    return Report(
      id: 999,
      tipoDeIncidente: _tipoPorNome(tipo),
      statusReport: StatusReport.PENDNTE,
      dataDoOcorrido: dataDoOcorrido,
      descricao: descricao,
      localizacao: 'Local informado no report',
      usuarioId: usuarioId,
      unidadeId: unidadeId,
      usuarioNome: 'Usuário Demo',
      unidadeNome: 'Parque Estadual de Exemplo',
    );
  }

  static TipoDeIncidente _tipoPorNome(String tipo) {
    for (final incidente in TipoDeIncidente.values) {
      if (incidente.name == tipo.toUpperCase()) return incidente;
    }

    return TipoDeIncidente.QUEIMADA;
  }

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
  /// Reports da tela "Seus Reports", no formato que o backend devolve.
  static List<ReportLista> buscarMeusReports() {
    return [
      ReportLista(
        id: 1,
        unidadeId: 1,
        unidadeNome: 'Parque Estadual de Exemplo',
        usuarioId: 2,
        usuarioNome: 'Usuário Demo',
        tipo: TipoDeIncidente.ANIMAL_FERIDO,
        status: StatusReport.PENDNTE,
        dataDoOcorrido: DateTime(2025, 9, 18, 10, 30),
        descricao: 'Animal ferido próximo à trilha principal.',
        quantidadeAnexos: 0,
      ),
      ReportLista(
        id: 2,
        unidadeId: 1,
        unidadeNome: 'Parque Estadual de Exemplo',
        usuarioId: 2,
        usuarioNome: 'Usuário Demo',
        tipo: TipoDeIncidente.QUEIMADA,
        status: StatusReport.SOB_AVALIACAO,
        dataDoOcorrido: DateTime(2025, 9, 14, 15, 5),
        descricao: 'Fogo na área de piquenique.',
        quantidadeAnexos: 2,
        supervisorNome: 'Supervisor Exemplo',
      ),
      ReportLista(
        id: 3,
        unidadeId: 1,
        unidadeNome: 'Parque Estadual de Exemplo',
        usuarioId: 2,
        usuarioNome: 'Usuário Demo',
        tipo: TipoDeIncidente.DESMATAMENTO,
        status: StatusReport.TRATADO,
        dataDoOcorrido: DateTime(2025, 9, 2, 8, 0),
        descricao: 'Corte de árvores na entrada do parque.',
        quantidadeAnexos: 1,
        supervisorNome: 'Supervisor Exemplo',
        dataDaAnalise: DateTime(2025, 9, 5),
      ),
      ReportLista(
        id: 4,
        unidadeId: 1,
        unidadeNome: 'Parque Estadual de Exemplo',
        usuarioId: 2,
        usuarioNome: 'Usuário Demo',
        tipo: TipoDeIncidente.POLUICAO,
        status: StatusReport.NEGADO,
        dataDoOcorrido: DateTime(2025, 8, 30, 12, 20),
        descricao: 'Descarte irregular às margens do riacho.',
        quantidadeAnexos: 0,
        supervisorNome: 'Supervisor Exemplo',
        dataDaAnalise: DateTime(2025, 9, 1),
        motivoDaNegacao: 'Fora da área monitorada.',
      ),
    ];
  }

}
