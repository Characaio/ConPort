import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/widgets/topbar.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/models/report.dart';


// ============================================================
// MOCK DOS REPORTS
// ============================================================

final List<Report> reportsMock = [
  Report(
    id: 1,
    tipoDeIncidente: TipoDeIncidente.ANIMAL_FERIDO,
    statusReport: StatusReport.TRATADO,
    dataDoOcorrido: DateTime(2026, 8, 8, 14, 30),
    descricao:
        'Resgatei um cachorro com sinais de maus-tratos em frente à minha casa.',
        localizacao: 'rua arceu nicolleti 64',
    imagensAnexadas: [
      'assets/images/mock.jpg',
    ],
    usuarioId: 1,
    unidadeId: 1,
    usuarioNome: 'Usuário Demo',
    unidadeNome: 'Unidade de Conservação',
    supervisorNome: 'Augusto Henrique Batista Rosa',
    dataDaAnalise: DateTime(2026, 8, 8, 18, 30),
  ),

  Report(
    id: 2,
    tipoDeIncidente: TipoDeIncidente.POLUICAO,
    statusReport: StatusReport.PENDNTE,
    dataDoOcorrido: DateTime(2025, 2, 16, 22, 15),
    descricao:
        'Foi encontrada uma ocorrência de poluição na região.',
        localizacao: 'rua do caralho',
    imagensAnexadas: [
      'assets/images/mock.jpg',
    ],
    usuarioId: 1,
    unidadeId: 1,
    usuarioNome: 'Usuário Demo',
    unidadeNome: 'Unidade de Conservação',
    supervisorNome: null,
    dataDaAnalise: null,
  ),
];


// ============================================================
// TELA MEUS REPORTS
// ============================================================

class Myrepo extends StatelessWidget {
  const Myrepo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Topbar(
              hasLogo: false,
              hasReturn: true,
              text: 'Meus reports',
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),

                  child: Column(
                    children: reportsMock.map((report) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReportCard(
                          report: report,
                          colors: colors,

                          onTap: () {
                            PageLoader.go(
                              context,
                              PageLoader.report,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CARD DO REPORT
// ============================================================

class _ReportCard extends StatelessWidget {
  final Report report;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.primary,
              width: 1.5,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // CABEÇALHO
              // ==================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(
                      _getReportIcon(report.tipoDeIncidente),
                      color: colors.onPrimaryContainer,
                      size: 25,
                      fill: 1,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          _getTipoNome(
                            report.tipoDeIncidente,
                          ),

                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [

                            Icon(
                              Symbols.explore,
                              size: 17,
                              color:
                                  colors.onSurfaceVariant,
                              fill: 1,
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                report.unidadeNome,

                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colors
                                          .onSurfaceVariant,
                                    ),

                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Symbols.chevron_right,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DATA
              // ==================================================

              Row(
                children: [

                  Icon(
                    Symbols.calendar_month,
                    size: 20,
                    color: colors.onSurfaceVariant,
                    fill: 1,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _formatDate(report.dataDoOcorrido),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==================================================
              // STATUS
              // ==================================================

              Row(
                children: [

                  Icon(
                    _getStatusIcon(
                      report.statusReport,
                    ),
                    size: 20,
                    color: _getStatusColor(
                      report.statusReport,
                    ),
                    fill: 1,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      _getStatusNome(
                        report.statusReport,
                      ),

                      style: TextStyle(
                        color: _getStatusColor(
                          report.statusReport,
                        ),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // IMAGEM
              // ==================================================

              if (report.imagensAnexadas != null &&
                  report.imagensAnexadas!.isNotEmpty) ...[
                const SizedBox(height: 10),

                Row(
                  children: [

                    Icon(
                      Symbols.image,
                      size: 20,
                      color:
                          colors.onSurfaceVariant,
                      fill: 1,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Imagem anexada',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  // ==========================================================
  // ÍCONE DO TIPO
  // ==========================================================

  IconData _getReportIcon(
    TipoDeIncidente tipo,
  ) {
    switch (tipo) {
      case TipoDeIncidente.ANIMAL_FERIDO:
        return Symbols.pets;

      case TipoDeIncidente.ANIMAL_EXOTICO:
        return Symbols.pets;

      case TipoDeIncidente.QUEIMADA:
        return Symbols.local_fire_department;

      case TipoDeIncidente.POLUICAO:
        return Symbols.cloud;

      case TipoDeIncidente.DESMATAMENTO:
        return Symbols.forest;
    }
  }


  // ==========================================================
  // NOME DO TIPO
  // ==========================================================

  String _getTipoNome(
    TipoDeIncidente tipo,
  ) {
    switch (tipo) {
      case TipoDeIncidente.QUEIMADA:
        return 'Queimada';

      case TipoDeIncidente.ANIMAL_FERIDO:
        return 'Animal ferido';

      case TipoDeIncidente.ANIMAL_EXOTICO:
        return 'Animal exótico';

      case TipoDeIncidente.POLUICAO:
        return 'Poluição';

      case TipoDeIncidente.DESMATAMENTO:
        return 'Desmatamento';
    }
  }


  // ==========================================================
  // NOME DO STATUS
  // ==========================================================

  String _getStatusNome(
    StatusReport status,
  ) {
    switch (status) {
      case StatusReport.PENDNTE:
        return 'Incidente pendente';

      case StatusReport.SOB_AVALIACAO:
        return 'Incidente sob avaliação';

      case StatusReport.NEGADO:
        return 'Incidente negado';

      case StatusReport.EM_TRATAMENTO:
        return 'Incidente em tratamento';

      case StatusReport.TRATADO:
        return 'Incidente resolvido';
    }
  }


  // ==========================================================
  // ÍCONE DO STATUS
  // ==========================================================

  IconData _getStatusIcon(
    StatusReport status,
  ) {
    switch (status) {
      case StatusReport.PENDNTE:
        return Symbols.pending;

      case StatusReport.SOB_AVALIACAO:
        return Symbols.manage_search;

      case StatusReport.NEGADO:
        return Symbols.cancel;

      case StatusReport.EM_TRATAMENTO:
        return Symbols.autorenew;

      case StatusReport.TRATADO:
        return Symbols.check_circle;
    }
  }


  // ==========================================================
  // COR DO STATUS
  // ==========================================================

  Color _getStatusColor(
    StatusReport status,
  ) {
    switch (status) {
      case StatusReport.PENDNTE:
        return Colors.orange;

      case StatusReport.SOB_AVALIACAO:
        return Colors.blue;

      case StatusReport.NEGADO:
        return Colors.red;

      case StatusReport.EM_TRATAMENTO:
        return Colors.orange;

      case StatusReport.TRATADO:
        return Colors.green;
    }
  }


  // ==========================================================
  // FORMATAÇÃO DA DATA
  // ==========================================================

  String _formatDate(
    DateTime date,
  ) {
    final dia = date.day
        .toString()
        .padLeft(2, '0');

    final mes = date.month
        .toString()
        .padLeft(2, '0');

    final ano = date.year.toString();

    final hora = date.hour
        .toString()
        .padLeft(2, '0');

    final minuto = date.minute
        .toString()
        .padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}