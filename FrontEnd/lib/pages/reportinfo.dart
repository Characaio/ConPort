import 'package:flutter/material.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/widgets/topbar.dart';

class ReportDetails extends StatelessWidget {
  const ReportDetails({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK TEMPORÁRIO
    const String tipo = 'Animal ferido';
    const String local = 'Jardim Europa';
    const String dataHora = '67/67/6767 67:67';
    const String status = 'Resolvido';
    const String revisor = 'Joãozinho Biologias da Silva';
    const String dataRevisao = '69/69/6969 69:69';

    const String descricao =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Nunc commodo turpis leo, ut fringilla lorem posuere a. '
        'Mauris ut tellus in justo venenatis tristique efficitur sit amet metus.';

    const double urgencia = 0.5;

    // Pode ser null quando não existir comentário.
    const String? comentarioRevisor = null;

    final scheme = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                text: 'Criar Report',
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    border: Border.all(color: appColors.accentGreen, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, tipo: tipo, local: local),

                      const SizedBox(height: 8),

                      _buildInfoLine(
                        context,
                        icon: Icons.calendar_month,
                        text: dataHora,
                      ),

                      const SizedBox(height: 7),

                      _buildStatusLine(context, status),

                      const SizedBox(height: 8),

                      _buildInfoLine(
                        context,
                        icon: Icons.person,
                        text: revisor,
                      ),

                      const SizedBox(height: 8),

                      _buildInfoLine(
                        context,
                        icon: Icons.calendar_month,
                        text: 'Revisado e aprovado em $dataRevisao',
                      ),

                      if (comentarioRevisor != null) ...[
                        const SizedBox(height: 14),

                        _buildSectionTitle('Comentário do revisor'),

                        const SizedBox(height: 3),

                        Text(
                          comentarioRevisor,
                          style: const TextStyle(fontSize: 12, height: 1.25),
                        ),
                      ],

                      const SizedBox(height: 19),

                      _buildSectionTitle('Descrição'),

                      const SizedBox(height: 3),

                      Text(
                        descricao,
                        style: const TextStyle(fontSize: 12, height: 1.2),
                      ),

                      const SizedBox(height: 17),

                      _buildSectionTitle('Urgência'),

                      const SizedBox(height: 3),

                      _buildUrgency(context, urgencia),

                      const SizedBox(height: 25),

                      _buildAttachments(context),

                      const SizedBox(height: 55),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String tipo,
    required String local,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: appColors.accentGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.pets, color: scheme.onPrimary, size: 24),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 1),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 13),

                  const SizedBox(width: 2),

                  Text(local, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoLine(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface),

        const SizedBox(width: 5),

        Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
      ],
    );
  }

  Widget _buildStatusLine(BuildContext context, String status) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      children: [
        Icon(Icons.check_circle, size: 14, color: colors.statusTreated),

        const SizedBox(width: 5),

        Text(
          status,
          style: TextStyle(fontSize: 11, color: colors.statusTreated),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildUrgency(BuildContext context, double value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(
              height: 4,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: scheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pouco',
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
            ),
            Text(
              'Muito',
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachments(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Imagem principal
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: double.infinity,
            height: 116,
            color: scheme.surfaceContainerHigh,
            child: Icon(Icons.image, size: 35, color: scheme.onSurfaceVariant),
          ),
        ),

        const SizedBox(height: 5),

        // Segunda linha
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  height: 149,
                  color: scheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  height: 149,
                  color: scheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
