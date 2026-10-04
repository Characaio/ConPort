import 'package:flutter/material.dart';
import 'package:conport/core/notificacoes/notificacao_controller.dart';
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
// POPUP
//
// A lista vem do NotificacaoController (que por sua vez chama a API), então o
// popup só desenha: o model e o mock saíram daqui e foram para
// lib/models/notificacao.dart e lib/mocks/notificacao_mock.dart.
// ============================================================

class _NotificacoesPopup extends StatefulWidget {
  const _NotificacoesPopup();

  @override
  State<_NotificacoesPopup> createState() => _NotificacoesPopupState();
}

class _NotificacoesPopupState extends State<_NotificacoesPopup> {
  final NotificacaoController _controller = NotificacaoController.instance;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_mudou);

    // Busca ao abrir: é o que traz as notificações novas e atualiza o sino.
    _controller.carregar();
  }

  @override
  void dispose() {
    _controller.removeListener(_mudou);
    super.dispose();
  }

  void _mudou() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final notificacoes = _controller.notificacoes;

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
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notificações',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_controller.temNaoLidas)
                      TextButton(
                        onPressed: _controller.marcarTodasComoLidas,
                        child: const Text(
                          'Marcar todas como lidas',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Falha de rede: avisa e mantém a lista antiga, em vez de
              // fingir que o usuário não tem notificações.
              if (_controller.erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    _controller.erro!,
                    style: TextStyle(fontSize: 11, color: colors.error),
                  ),
                ),

              if (_controller.carregando && notificacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (notificacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
                  child: Text(
                    'Você não tem notificações.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                Flexible(
                  child: RefreshIndicator(
                    onRefresh: _controller.carregar,
                    child: ListView.separated(
                      shrinkWrap: true,
                      // Sem isso o puxar-para-atualizar não funciona quando a
                      // lista é curta demais para rolar.
                      physics: const AlwaysScrollableScrollPhysics(),
                      // espaço para o ponto vermelho, que fica um pouco para fora
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      itemCount: notificacoes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = notificacoes[index];

                        return _CardNotificacao(
                          notificacao: n,
                          onTap: () => _controller.marcarComoLida(n.id),
                        );
                      },
                    ),
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
