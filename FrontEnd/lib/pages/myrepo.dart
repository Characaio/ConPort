import 'package:conport/core/navigation/page_loader.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';

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
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    children: [
                      _ReportCard(
                        title: 'Animal ferido',
                        location: 'Jardim Europa',
                        date: '08/08/2026 14:30',
                        status: 'Incidente resolvido',
                        statusColor: Colors.green,
                        statusIcon: Symbols.check_circle,
                        hasImage: true,
                        colors: colors,
                        onTap: () {
                          PageLoader.go(context, PageLoader.report);
                        },
                      ),

                      const SizedBox(height: 12),

                      _ReportCard(
                        title: 'Poluição',
                        location: 'Avenida São Paulo',
                        date: '16/02/2025 22:15',
                        status: 'Incidente pendente',
                        statusColor: Colors.orange,
                        statusIcon: Symbols.pending,
                        hasImage: true,
                        colors: colors,
                        onTap: () {
                          // TODO: abrir Dtrepo
                        },
                      ),

                      const SizedBox(height: 12),

                      _ReportCard(
                        title: '...',
                        location: '...',
                        date: '../../.... ..:..',
                        status: '...',
                        statusColor: colors.onSurfaceVariant,
                        statusIcon: Symbols.pending,
                        hasImage: false,
                        colors: colors,
                        onTap: () {
                          // TODO: abrir Dtrepo
                        },
                      ),
                    ],
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

class _ReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final bool hasImage;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.hasImage,
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
            border: Border.all(color: colors.primary, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
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
                      _getReportIcon(title),
                      color: colors.onPrimaryContainer,
                      size: 25,
                      fill: 1,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Symbols.explore,
                              size: 17,
                              color: colors.onSurfaceVariant,
                              fill: 1,
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                location,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(Symbols.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),

              const SizedBox(height: 16),

              // Informações
              Row(
                children: [
                  Icon(
                    Symbols.calendar_month,
                    size: 20,
                    color: colors.onSurfaceVariant,
                    fill: 1,
                  ),

                  const SizedBox(width: 7),

                  Text(date, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),

              const SizedBox(height: 10),

              // Status
              Row(
                children: [
                  Icon(statusIcon, size: 20, color: statusColor, fill: 1),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (hasImage) ...[
                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Symbols.image,
                      size: 20,
                      color: colors.onSurfaceVariant,
                      fill: 1,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Imagem anexada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
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

  IconData _getReportIcon(String title) {
    switch (title.toLowerCase()) {
      case 'animal ferido':
        return Symbols.pets;

      case 'poluição':
        return Symbols.cloud;

      default:
        return Symbols.report;
    }
  }
}
