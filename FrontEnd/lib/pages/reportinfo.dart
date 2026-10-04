import 'package:flutter/material.dart';

import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/report.dart';
import 'package:conport/models/report_lista.dart';
import 'package:conport/widgets/topbar.dart';

/// Detalhe de um report enviado pelo usuário.
///
/// Os dados vêm do [report] que a lista entrega; não busca de novo, para a
/// tela abrir na hora e funcionar com o que já está em memória.
class ReportDetails extends StatelessWidget {
  final ReportLista report;

  const ReportDetails({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final tipo = _tipoLabel(report.tipo);
    final local = report.localizacao;
    final dataHora = _formatarData(report.dataDoOcorrido);
    final status = _statusLabel(report.status);

    // Ainda não analisado: não há revisor nem data de análise.
    final revisor = report.supervisorNome;
    final dataRevisao = report.dataDaAnalise == null
        ? null
        : _formatarData(report.dataDaAnalise!);

    final descricao = report.descricao;
    final comentarioRevisor = report.motivoDaNegacao;

    final urgencia = _urgencia(report.tipo, report.prioridade);

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
                text: 'Report',
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
                      _buildHeader(
                        context,
                        tipo: tipo,
                        local: local,
                        icone: _tipoIcon(report.tipo),
                      ),

                      const SizedBox(height: 8),

                      _buildInfoLine(
                        context,
                        icon: Icons.calendar_month,
                        text: dataHora,
                      ),

                      const SizedBox(height: 7),

                      _buildStatusLine(context, status, report.status),

                      const SizedBox(height: 8),

                      _buildInfoLine(
                        context,
                        icon: Icons.person,
                        text: revisor == null
                            ? 'Aguardando análise de um supervisor'
                            : 'Analisado por $revisor',
                      ),

                      if (dataRevisao != null) ...[
                        const SizedBox(height: 8),

                        _buildInfoLine(
                          context,
                          icon: Icons.calendar_month,
                          text: 'Analisado em $dataRevisao',
                        ),
                      ],

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
    required IconData icone,
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
          child: Icon(icone, color: scheme.onPrimary, size: 24),
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

  Widget _buildStatusLine(
    BuildContext context,
    String status,
    StatusReport reportStatus,
  ) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    final cor = switch (reportStatus) {
      StatusReport.PENDNTE || StatusReport.SOB_AVALIACAO => colors.statusPending,
      StatusReport.EM_TRATAMENTO => colors.statusInProgress,
      StatusReport.TRATADO => colors.statusTreated,
      StatusReport.NEGADO => colors.statusDenied,
    };

    final icone = switch (reportStatus) {
      StatusReport.PENDNTE || StatusReport.SOB_AVALIACAO => Icons.more_horiz,
      StatusReport.EM_TRATAMENTO => Icons.autorenew,
      StatusReport.TRATADO => Icons.check_circle,
      StatusReport.NEGADO => Icons.cancel,
    };

    return Row(
      children: [
        Icon(icone, size: 14, color: cor),

        const SizedBox(width: 5),

        Text(
          status,
          style: TextStyle(fontSize: 11, color: cor),
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

            // Animada: antes a barra aparecia já cheia, sem dar a ideia de
            // quanto do caminho foi percorrido.
            _BarraUrgencia(valor: value, cor: scheme.tertiary),
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

// ============================================================
// FORMATADORES
// ============================================================

String _tipoLabel(TipoDeIncidente tipo) {
  return switch (tipo) {
    TipoDeIncidente.QUEIMADA => 'Queimada',
    TipoDeIncidente.ANIMAL_FERIDO => 'Animal ferido',
    TipoDeIncidente.ANIMAL_EXOTICO => 'Animal exótico',
    TipoDeIncidente.POLUICAO => 'Poluição',
    TipoDeIncidente.DESMATAMENTO => 'Desmatamento',
  };
}

IconData _tipoIcon(TipoDeIncidente tipo) {
  return switch (tipo) {
    TipoDeIncidente.QUEIMADA => Icons.local_fire_department,
    TipoDeIncidente.ANIMAL_FERIDO => Icons.pets,
    TipoDeIncidente.ANIMAL_EXOTICO => Icons.cruelty_free,
    TipoDeIncidente.POLUICAO => Icons.water_drop,
    TipoDeIncidente.DESMATAMENTO => Icons.forest,
  };
}

String _statusLabel(StatusReport status) {
  return switch (status) {
    StatusReport.PENDNTE => 'Pendente',
    StatusReport.SOB_AVALIACAO => 'Sob avaliação',
    StatusReport.EM_TRATAMENTO => 'Em tratamento',
    StatusReport.TRATADO => 'Tratado',
    StatusReport.NEGADO => 'Negado',
  };
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year} $hora:$minuto';
}

/// Urgência do report: usa a prioridade que o usuário escolheu no envio
/// (BAIXA, MEDIA, ALTA, ALARMANTE). Sem ela — report antigo ou mock — cai
/// num valor por tipo, só para a barra não ficar vazia.
double _urgencia(TipoDeIncidente tipo, String? prioridade) {
  switch (prioridade?.toUpperCase()) {
    case 'BAIXA':
      return 0.25;
    case 'MEDIA':
      return 0.5;
    case 'ALTA':
      return 0.75;
    case 'ALARMANTE':
      return 1;
  }

  return switch (tipo) {
    TipoDeIncidente.QUEIMADA => 0.85,
    TipoDeIncidente.DESMATAMENTO => 0.7,
    TipoDeIncidente.ANIMAL_FERIDO => 0.6,
    TipoDeIncidente.ANIMAL_EXOTICO => 0.5,
    TipoDeIncidente.POLUICAO => 0.4,
  };
}

/// Barra de urgência que cresce do zero até [valor] quando a tela abre.
class _BarraUrgencia extends StatefulWidget {
  final double valor;
  final Color cor;

  const _BarraUrgencia({required this.valor, required this.cor});

  @override
  State<_BarraUrgencia> createState() => _BarraUrgenciaState();
}

class _BarraUrgenciaState extends State<_BarraUrgencia>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animacao;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _animacao = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    )..addListener(() => setState(() {}));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _BarraUrgencia anterior) {
    super.didUpdateWidget(anterior);

    // O mesmo report reconstrói com o valorAnimationso; refaz a animação.
    if (anterior.valor != widget.valor) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valor = widget.valor.clamp(0.0, 1.0);

    return FractionallySizedBox(
      widthFactor: valor * _animacao.value,
      child: Container(
        height: 4,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: widget.cor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
