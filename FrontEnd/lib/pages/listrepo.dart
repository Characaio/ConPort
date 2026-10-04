import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/report.dart';
import 'package:conport/models/report_lista.dart';
import 'package:conport/pages/reportinfo.dart';
import 'package:conport/services/reportService.dart';
import 'package:conport/widgets/topbar.dart';

/// "Seus Reports": os reports enviados pelo usuário da sessão, com uma aba
/// por status.
class SeusReports extends StatefulWidget {
  const SeusReports({super.key});

  @override
  State<SeusReports> createState() => _SeusReportsState();
}

enum _Aba { pendente, avaliacao, andamento, tratado, negado }

enum _AbaInfo {
  pendente('Pendentes'),
  avaliacao('Sob avaliação'),
  andamento('Em andamento'),
  tratado('Tratados'),
  negado('Negados');

  const _AbaInfo(this.rotulo);

  final String rotulo;

  _Aba get aba => _Aba.values[index];

  List<ReportLista> aplicar(List<ReportLista> reports) => switch (this) {
        _AbaInfo.pendente => reports
            .where((r) => r.status == StatusReport.PENDNTE)
            .toList(),
        _AbaInfo.avaliacao => reports
            .where((r) => r.status == StatusReport.SOB_AVALIACAO)
            .toList(),
        _AbaInfo.andamento => reports
            .where((r) => r.status == StatusReport.EM_TRATAMENTO)
            .toList(),
        _AbaInfo.tratado => reports
            .where((r) => r.status == StatusReport.TRATADO)
            .toList(),
        _AbaInfo.negado =>
          reports.where((r) => r.status == StatusReport.NEGADO).toList(),
      };

  static List<_AbaInfo> comAlgum(List<ReportLista> reports) =>
      _AbaInfo.values
          .where((aba) => aba.aplicar(reports).isNotEmpty)
          .toList();
}

class _SeusReportsState extends State<SeusReports> {
  final ReportService _reportService = ReportService();

  List<ReportLista> _reports = [];
  _Aba _aba = _Aba.pendente;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final usuario = AuthSession.instance.usuario;

    if (usuario == null) {
      setState(() {
        _erro = 'Entre na sua conta para ver seus reports.';
        _carregando = false;
      });
      return;
    }

    try {
      final lista = await _reportService.buscarMeusReports(usuario.id);

      if (!mounted) return;

      setState(() {
        _reports = lista;
        _carregando = false;

        // Abre numa aba que tenha algo, senão a lista parece vazia.
        final comAlgo = _AbaInfo.comAlgum(lista);
        _aba = comAlgo.isEmpty ? _Aba.pendente : comAlgo.first.aba;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar seus reports.';
        _carregando = false;
      });
    }
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
            Expanded(child: _corpo()),
          ],
        ),
      ),
    );
  }

  Widget _corpo() {
    final colors = Theme.of(context).colorScheme;

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _erro!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você ainda não enviou nenhum report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    final abaAtual = _AbaInfo.values[_aba.index];
    final visiveis = abaAtual.aplicar(_reports);

    return Column(
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final info in _AbaInfo.values)
                if (info.aplicar(_reports).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _AbaButton(
                      rotulo: info.rotulo,
                      quantidade: info.aplicar(_reports).length,
                      selecionada: info.aba == _aba,
                      onTap: () => setState(() => _aba = info.aba),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: visiveis.isEmpty
              ? Center(
                  child: Text(
                    'Nada com este status.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  itemCount: visiveis.length,
                  itemBuilder: (context, index) =>
                      _ReportCard(report: visiveis[index]),
                ),
        ),
      ],
    );
  }
}

class _AbaButton extends StatelessWidget {
  final String rotulo;
  final int quantidade;
  final bool selecionada;
  final VoidCallback onTap;

  const _AbaButton({
    required this.rotulo,
    required this.quantidade,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final cor = selecionada
        ? appColors.accentGreen
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Material(
      color: cor,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$rotulo ($quantidade)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selecionada ? FontWeight.w700 : FontWeight.w500,
                  color: selecionada
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportLista report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context, report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.28),
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetails(report: report),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _tipoIcon(report.tipo),
                    color: scheme.onSurface,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tipoLabel(report.tipo),
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
                              report.localizacao,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatarData(report.dataDoOcorrido),
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
                          Icon(
                            _statusIcon(report.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(report.status),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.descricao,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9, color: scheme.onSurface),
                      ),
                      if (report.motivoDaNegacao != null &&
                          report.motivoDaNegacao!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              size: 14,
                              color: scheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.motivoDaNegacao!,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (report.quantidadeAnexos > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 12,
                          color: scheme.onSurface,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${report.quantidadeAnexos}',
                          style: TextStyle(
                            fontSize: 9,
                            color: scheme.onSurface,
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

IconData _tipoIcon(TipoDeIncidente tipo) {
  return switch (tipo) {
    TipoDeIncidente.QUEIMADA => Icons.local_fire_department,
    TipoDeIncidente.ANIMAL_FERIDO => Icons.pets,
    TipoDeIncidente.ANIMAL_EXOTICO => Icons.cruelty_free,
    TipoDeIncidente.POLUICAO => Icons.water_drop,
    TipoDeIncidente.DESMATAMENTO => Icons.forest,
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
    StatusReport.EM_TRATAMENTO => 'Em tratamento',
    StatusReport.TRATADO => 'Tratado',
    StatusReport.NEGADO => 'Negado',
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
    StatusReport.SOB_AVALIACAO || StatusReport.PENDNTE => Icons.more_horiz,
    StatusReport.EM_TRATAMENTO => Icons.autorenew,
    StatusReport.TRATADO => Icons.check_circle,
    StatusReport.NEGADO => Icons.cancel,
  };
}