import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';

class Dtrepo extends StatelessWidget {
  const Dtrepo({super.key});

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
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.primary, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Symbols.pets,
                                  color: Colors.white,
                                  size: 28,
                                  fill: 1,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Animal ferido',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      'Ocorrência registrada',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              _StatusChip(
                                text: 'Resolvido',
                                color: Colors.green,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Informações principais
                          _SectionTitle(
                            icon: Symbols.info,
                            title: 'Informações',
                          ),

                          const SizedBox(height: 12),

                          _InfoRow(
                            icon: Symbols.explore,
                            title: 'Localização',
                            value:
                                'Jardim Europa R. Escócia, 491-191 - Pinheiros',
                          ),

                          const SizedBox(height: 12),

                          _InfoRow(
                            icon: Symbols.calendar_month,
                            title: 'Relatado',
                            value: '08/08/2026 às 14:30',
                          ),

                          const SizedBox(height: 12),

                          _InfoRow(
                            icon: Symbols.check_circle,
                            title: 'Resolvido',
                            value: '08/08/2026 às 18:30',
                            valueColor: Colors.green,
                          ),

                          const SizedBox(height: 24),

                          // Descrição
                          _SectionTitle(
                            icon: Symbols.description,
                            title: 'Descrição',
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Resgatei um cachorro com sinais de maus-tratos em frente à minha casa.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(height: 1.5),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Análise
                          _SectionTitle(
                            icon: Symbols.edit_note,
                            title: 'Análise',
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Symbols.person,
                                  size: 24,
                                  color: colors.onSurfaceVariant,
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
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        'Augusto Henrique Batista Rosa',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          Icon(
                                            Symbols.check_circle,
                                            size: 18,
                                            color: Colors.green,
                                          ),

                                          const SizedBox(width: 6),

                                          Text(
                                            'Incidente resolvido',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
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

                          // Anexos
                          _SectionTitle(
                            icon: Symbols.attach_file,
                            title: 'Anexos',
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _AttachmentCard(
                                icon: Symbols.image,
                                name: 'Anexo 1',
                                colors: colors,
                              ),
                              _AttachmentCard(
                                icon: Symbols.image,
                                name: 'Anexo 2',
                                colors: colors,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colors.primary, fill: 1),

        const SizedBox(width: 8),

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
        Icon(icon, size: 22, color: colors.onSurfaceVariant, fill: 1),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.check_circle, size: 17, color: color, fill: 1),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final ColorScheme colors;

  const _AttachmentCard({
    required this.icon,
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
        border: Border.all(color: colors.outlineVariant),
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
            child: Icon(icon, color: colors.onPrimaryContainer, fill: 1),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
