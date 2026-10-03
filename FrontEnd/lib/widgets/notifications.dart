import 'package:flutter/material.dart';
import 'package:conport/core/theme/app_theme.dart';

// ============================================================
// API PÚBLICA
// Chame de qualquer tela: mostrarNotificacoes(context);
// ============================================================

Future<void> mostrarNotificacoes(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
    builder: (_) => const _NotificacoesPopup(),
  );
}

// ============================================================
// MODELO + MOCK (temporário, até existir na API)
// Quando o backend tiver o endpoint, mova Notificacao para
// lib/models/notificacao.dart e crie um NotificacaoService.
// ============================================================

class Notificacao {
  final int id;
  final String titulo;
  final String texto;
  final DateTime data;
  final bool lida;

  const Notificacao({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.data,
    this.lida = false,
  });

  Notificacao copyWith({bool? lida}) {
    return Notificacao(
      id: id,
      titulo: titulo,
      texto: texto,
      data: data,
      lida: lida ?? this.lida,
    );
  }
}

class _NotificacoesMock {
  static const String _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Nunc commodo turpis leo, ut fringilla lorem posuere a.';

  static List<Notificacao> listar() {
    final agora = DateTime.now();

    return [
      for (int i = 1; i <= 6; i++)
        Notificacao(
          id: i,
          titulo: 'Notificação',
          texto: _lorem,
          data: agora.subtract(Duration(hours: i * 5)),
          lida: i != 1, // só a primeira é não lida
        ),
    ];
  }
}

// ============================================================
// POPUP
// ============================================================

class _NotificacoesPopup extends StatefulWidget {
  const _NotificacoesPopup();

  @override
  State<_NotificacoesPopup> createState() => _NotificacoesPopupState();
}

class _NotificacoesPopupState extends State<_NotificacoesPopup> {
  late List<Notificacao> notificacoes;

  @override
  void initState() {
    super.initState();

    notificacoes = _NotificacoesMock.listar()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  void _marcarComoLida(int id) {
    setState(() {
      notificacoes = [
        for (final n in notificacoes) n.id == id ? n.copyWith(lida: true) : n,
      ];
    });

    // TODO: avisar a API que a notificação foi lida.
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colors.surfaceContainerHighest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 480, // não esticar demais no PC
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Notificações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),

              if (notificacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
                  child: Text(
                    'Você não tem notificações.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    // espaço para o ponto vermelho, que fica um pouco para fora
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    itemCount: notificacoes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = notificacoes[index];

                      return _CardNotificacao(
                        notificacao: n,
                        onTap: () => _marcarComoLida(n.id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD
// ============================================================

class _CardNotificacao extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onTap;

  const _CardNotificacao({required this.notificacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: notificacao.lida
              ? appColors.mutedBackground
              : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificacao.titulo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    notificacao.texto,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (!notificacao.lida)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: scheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
