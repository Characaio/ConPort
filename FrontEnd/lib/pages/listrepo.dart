import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/services/reportService.dart';
import 'package:conport/models/report.dart';

class SeusReports extends StatefulWidget {
  const SeusReports({super.key});

  @override
  State<SeusReports> createState() => _SeusReportsState();
}

class _SeusReportsState extends State<SeusReports> {
  final ReportService _reportService = ReportService();

  Future<List<Report>> _buscarReports() {
    return _reportService.buscarReportsDaUnidade(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                text: 'Seus Reports',
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Report>>(
                future: _buscarReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar reports: ${snapshot.error}',
                      ),
                    );
                  }

                  final reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return const Center(
                      child: Text('Nenhum report encontrado.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      return NovoReportCard(
                        titulo: _tipoLabel(report.tipoDeIncidente),
                        localizacao: report.localizacao,
                        dataDoOcorrido: report.dataDoOcorrido,
                        status: _statusLabel(report.statusReport),
                        motivo: report.descricao,
                        autor: report.usuarioNome,
                        statusColor: _statusColor(context, report.statusReport),
                        statusIcon: _statusIcon(report.statusReport),
                        quantidadeAnexos: 0,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _tipoLabel(TipoDeIncidente tipo) {
  return switch (tipo) {
    TipoDeIncidente.QUEIMADA => 'Queimada',
    TipoDeIncidente.ANIMAL_FERIDO => 'Animal ferido',
    TipoDeIncidente.ANIMAL_EXOTICO => 'Animal exótico',
    TipoDeIncidente.POLUICAO => 'Poluição',
    TipoDeIncidente.DESMATAMENTO => 'Desmatamento',
  };
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year} $hora:$minuto';
}

String _statusLabel(StatusReport status) {
  return switch (status) {
    StatusReport.PENDNTE => 'Pendente',
    StatusReport.SOB_AVALIACAO => 'Sob avaliação',
    StatusReport.NEGADO => 'Negado',
    StatusReport.EM_TRATAMENTO => 'Em andamento',
    StatusReport.TRATADO => 'Tratado',
  };
}

Color _statusColor(BuildContext context, StatusReport status) {
  final colors =
      Theme.of(context).extension<AppColors>() ?? AppColors.light;
  return switch (status) {
    StatusReport.SOB_AVALIACAO || StatusReport.PENDNTE => colors.statusPending,
    StatusReport.EM_TRATAMENTO => colors.statusInProgress,
    StatusReport.TRATADO => colors.statusTreated,
    StatusReport.NEGADO => colors.statusDenied,
  };
}

IconData _statusIcon(StatusReport status) {
  return switch (status) {
    StatusReport.SOB_AVALIACAO || StatusReport.PENDNTE => Symbols.more_horiz,
    StatusReport.EM_TRATAMENTO => Symbols.autorenew,
    StatusReport.TRATADO => Symbols.check_circle,
    StatusReport.NEGADO => Symbols.cancel,
  };
}

// ======================================================
// NOVO CARD DE REPORT
// ======================================================

class NovoReportCard extends StatelessWidget {
  final String titulo;
  final String localizacao;
  final DateTime dataDoOcorrido;
  final String status;
  final String? motivo;
  final String? autor;
  final int quantidadeAnexos;
  final Color statusColor;
  final IconData statusIcon;

  final bool mostrarImagem;

  const NovoReportCard({
    super.key,
    required this.titulo,
    required this.localizacao,
    required this.dataDoOcorrido,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.quantidadeAnexos,
    this.motivo,
    this.autor,
    this.mostrarImagem = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.28),
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(13),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(13),

        // ==========================================
        // NAVEGAÇÃO FUTURA
        // ==========================================
        onTap: () {
          PageLoader.go(context, PageLoader.report);
        },

        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // ÍCONE DO ANIMAL
              // ==========================================
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Icon(Symbols.pets, color: scheme.onSurface, size: 28),
              ),

              const SizedBox(width: 7),

              // ==========================================
              // INFORMAÇÕES
              // ==========================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Row(
                      children: [
                        Icon(
                          Symbols.explore,
                          size: 13,
                          color: scheme.onSurface,
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            localizacao,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Symbols.calendar_month,
                          size: 14,
                          color: scheme.onSurface,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatarData(dataDoOcorrido),
                          style: TextStyle(
                            fontSize: 9,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),

                        const SizedBox(width: 4),

                        Text(
                          status,
                          style: TextStyle(fontSize: 9, color: statusColor),
                        ),
                      ],
                    ),

                    // ======================================
                    // MOTIVO
                    // ======================================
                    if (motivo != null) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Symbols.info,
                            size: 14,
                            color: scheme.onSurface,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            motivo!,
                            style: TextStyle(
                              fontSize: 9,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ======================================
                    // AUTOR
                    // ======================================
                    if (autor != null) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Symbols.person,
                            size: 14,
                            color: scheme.onSurface,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              'Por $autor',
                              style: TextStyle(
                                fontSize: 9,
                                color: scheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ==========================================
              // ANEXOS
              // ==========================================
              if (quantidadeAnexos > 0) ...[
                const SizedBox(width: 8),

                SizedBox(
                  width: 88,
                  height: 88,

                  child: Stack(
                    children: [
                      if (quantidadeAnexos >= 2)
                        Positioned(
                          left: 7,
                          top: 4,
                          child: Container(
                            width: 80,
                            height: 88,

                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 80,
                          height: 88,

                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
