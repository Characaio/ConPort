import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/models/report.dart';
import 'package:conport/services/reportService.dart';

class Dtrepo extends StatefulWidget {
  final int reportId;

  const Dtrepo({
    super.key,
    this.reportId = 1,
  });

  @override
  State<Dtrepo> createState() => _DtrepoState();
}

class _DtrepoState extends State<Dtrepo> {

  String nomeTipo(TipoDeIncidente tipo) {
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

  String nomeStatus(StatusReport status) {
    switch (status) {
      case StatusReport.PENDNTE:
        return 'Pendente';
      case StatusReport.SOB_AVALIACAO:
        return 'Sob avaliação';
      case StatusReport.NEGADO:
        return 'Negado';
      case StatusReport.EM_TRATAMENTO:
        return 'Em tratamento';
      case StatusReport.TRATADO:
        return 'Resolvido';
    }
  }

  Color corStatus(StatusReport status) {
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

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  IconData iconeTipo(TipoDeIncidente tipo) {
    switch (tipo) {
      case TipoDeIncidente.QUEIMADA:
        return Symbols.local_fire_department;
      case TipoDeIncidente.ANIMAL_FERIDO:
        return Symbols.pets;
      case TipoDeIncidente.ANIMAL_EXOTICO:
        return Symbols.pets;
      case TipoDeIncidente.POLUICAO:
        return Symbols.cloud;
      case TipoDeIncidente.DESMATAMENTO:
        return Symbols.forest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reportService = ReportService();

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
              text: 'Detalhes do report',
            ),
          ),

          Expanded(
            child: FutureBuilder<Report>(
              future: reportService.buscarReportCompleto(widget.reportId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Erro ao carregar report:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Report não encontrado.'),
                  );
                }

                final report = snapshot.data!;

                final statusColor = corStatus(report.statusReport);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      iconeTipo(
                                        report.tipoDeIncidente,
                                      ),
                                      color: Colors.white,
                                      size: 28,
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
                                          nomeTipo(
                                            report.tipoDeIncidente,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          'Report #${report.id}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colors
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  _StatusChip(
                                    text: nomeStatus(
                                      report.statusReport,
                                    ),
                                    color: statusColor,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              _SectionTitle(
                                icon: Symbols.info,
                                title: 'Informações',
                              ),

                              const SizedBox(height: 12),

                              _InfoRow(
                                icon: Symbols.calendar_month,
                                title: 'Relatado',
                                value: formatarData(
                                  report.dataDoOcorrido,
                                ),
                              ),

                              const SizedBox(height: 12),

                              _InfoRow(
                                icon: Symbols.person,
                                title: 'Usuário',
                                value: report.usuarioNome,
                              ),

                              const SizedBox(height: 12),

                              _InfoRow(
                                icon: Symbols.forest,
                                title: 'Unidade',
                                value: report.unidadeNome,
                              ),

                              if (report.dataDaAnalise != null) ...[
                                const SizedBox(height: 12),

                                _InfoRow(
                                  icon: Symbols.check_circle,
                                  title: 'Analisado em',
                                  value: formatarData(
                                    report.dataDaAnalise!,
                                  ),
                                  valueColor: Colors.green,
                                ),
                              ],

                              const SizedBox(height: 24),

                              _SectionTitle(
                                icon: Symbols.description,
                                title: 'Descrição',
                              ),

                              const SizedBox(height: 12),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors
                                      .surfaceContainerHighest,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.descricao,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        height: 1.5,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              if (report.supervisorNome != null) ...[
                                _SectionTitle(
                                  icon: Symbols.edit_note,
                                  title: 'Análise',
                                ),

                                const SizedBox(height: 12),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          colors.outlineVariant,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Symbols.person,
                                        size: 24,
                                        color:
                                            colors.onSurfaceVariant,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Autor da análise',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: colors
                                                        .onSurfaceVariant,
                                                  ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              report.supervisorNome!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                            ),

                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                Icon(
                                                  Symbols.check_circle,
                                                  size: 18,
                                                  color: statusColor,
                                                ),

                                                const SizedBox(width: 6),

                                                Text(
                                                  nomeStatus(
                                                    report.statusReport,
                                                  ),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],

                              if (report.imagensAnexadas != null &&
                                  report.imagensAnexadas!.isNotEmpty) ...[
                                _SectionTitle(
                                  icon: Symbols.attach_file,
                                  title: 'Anexos',
                                ),

                                const SizedBox(height: 12),

                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (int i = 0;
                                        i <
                                            report.imagensAnexadas!
                                                .length;
                                        i++)
                                      _AttachmentCard(
                                        name: 'Anexo ${i + 1}',
                                        colors: colors,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: colors.primary,
          fill: 1,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: colors.onSurfaceVariant,
          fill: 1,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color: valueColor,
                      fontWeight: valueColor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.check_circle,
            size: 17,
            color: color,
            fill: 1,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String name;
  final ColorScheme colors;

  const _AttachmentCard({
    required this.name,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Symbols.image,
              color: colors.onPrimaryContainer,
              fill: 1,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              name,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
} 