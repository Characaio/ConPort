import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/amigo.dart';
import 'package:conport/services/usuarioService.dart';

/// Abre a folha com quem alguém segue ou quem segue essa pessoa.
///
/// Devolve a pessoa escolhida (ou `null`), para quem chamou abrir o perfil
/// depois que a folha fechar: empurrar a rota de dentro da folha brigaria
/// com a animação de saída.
Future<Amigo?> mostrarListaDePessoas(
  BuildContext context, {
  required String titulo,
  required int usuarioId,
  required int? visorId,
  required Future<List<Amigo>> Function(int usuarioId, {int? visorId}) carregar,
}) {
  return showModalBottomSheet<Amigo>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _ListaDePessoas(
      titulo: titulo,
      usuarioId: usuarioId,
      visorId: visorId,
      carregar: carregar,
    ),
  );
}

class _ListaDePessoas extends StatefulWidget {
  final String titulo;
  final int usuarioId;
  final int? visorId;
  final Future<List<Amigo>> Function(int usuarioId, {int? visorId}) carregar;

  const _ListaDePessoas({
    required this.titulo,
    required this.usuarioId,
    required this.visorId,
    required this.carregar,
  });

  @override
  State<_ListaDePessoas> createState() => _ListaDePessoasState();
}

class _ListaDePessoasState extends State<_ListaDePessoas> {
  List<Amigo>? _pessoas;
  String? _motivoPrivado;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _pessoas = null;
      _erro = null;
      _motivoPrivado = null;
    });

    try {
      final lista = await widget.carregar(
        widget.usuarioId,
        visorId: widget.visorId,
      );

      if (!mounted) return;

      setState(() => _pessoas = lista);
    } on ListaPrivada catch (e) {
      if (!mounted) return;
      setState(() => _motivoPrivado = e.motivo);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar a lista.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        // 80% da altura: numa lista curta não faz sentido ocupar a tela toda.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(child: _corpo()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _corpo() {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    if (_motivoPrivado != null) {
      return _Aviso(
        icone: Icons.lock_outline,
        texto: _motivoPrivado!,
        cor: appColors.onAccent,
      );
    }

    if (_erro != null) {
      return _Aviso(
        icone: Icons.cloud_off,
        texto: _erro!,
        cor: colors.error,
        aoTentarNovamente: _carregar,
      );
    }

    final pessoas = _pessoas;

    if (pessoas == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pessoas.isEmpty) {
      return _Aviso(
        icone: Symbols.group,
        texto: 'Ninguém por aqui ainda.',
        cor: colors.onSurfaceVariant,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: pessoas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final pessoa = pessoas[index];

        return ListTile(
          dense: true,
          leading: _AvatarPessoa(pessoa: pessoa),
          title: Text(
            pessoa.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '@${pessoa.username ?? 'sem username'} • Nível ${pessoa.nivel}',
            style: const TextStyle(fontSize: 10),
          ),
          trailing: const Icon(Symbols.chevron_right, size: 18),
          onTap: () => Navigator.pop(context, pessoa),
        );
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color cor;
  final VoidCallback? aoTentarNovamente;

  const _Aviso({
    required this.icone,
    required this.texto,
    required this.cor,
    this.aoTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 34, color: cor),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cor),
          ),
          if (aoTentarNovamente != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: aoTentarNovamente,
              icon: const Icon(Symbols.refresh, size: 18),
              label: const Text('Tentar de novo', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarPessoa extends StatelessWidget {
  final Amigo pessoa;

  const _AvatarPessoa({required this.pessoa});

  @override
  Widget build(BuildContext context) {
    final url = pessoa.avatarUrl;

    return CircleAvatar(
      radius: 20,
      backgroundImage: url == null ? null : NetworkImage(url),
      onBackgroundImageError: url == null ? null : (error, stackTrace) {},
      child: url == null
          ? const Icon(Symbols.person, size: 24, color: Colors.black)
          : null,
    );
  }
}
