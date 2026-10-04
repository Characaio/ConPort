import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/aviso.dart';
import 'package:conport/services/aviso_service.dart';
import 'package:conport/services/unidadeService.dart';
import 'package:conport/widgets/topbar.dart';

/// Anúncios da unidade de conservação.
///
/// Os dados vêm de `GET /unidade/{unidadeId}/aviso?limite=50`; com a API
/// desligada o [AvisoMock] devolve a mesma lista.
class Anuncios extends StatefulWidget {
  final int unidadeId;

  const Anuncios({super.key, this.unidadeId = 1});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  final AvisoService _avisoService = const AvisoService();
  final UnidadeService _unidadeService = const UnidadeService();

  List<Aviso> anuncios = [];
  String nomeUnidade = 'Unidade de Conservação';
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();

    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final lista = await _avisoService.listarAvisos(widget.unidadeId);

      // Fixados sempre no topo; dentro de cada grupo, mais recentes primeiro.
      lista.sort((a, b) {
        if (a.fixado != b.fixado) return a.fixado ? -1 : 1;
        return b.data.compareTo(a.data);
      });

      if (!mounted) return;
      setState(() => anuncios = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }

    _carregarNomeDaUnidade();
  }

  Future<void> _carregarNomeDaUnidade() async {
    try {
      final unidade = await _unidadeService.buscarStatusGeral(widget.unidadeId);

      if (!mounted) return;
      setState(() => nomeUnidade = unidade.nome);
    } catch (e) {
      // O nome é um detalhe: a lista de anúncios continua válida sem ele.
      debugPrint('Erro ao buscar nome da unidade: $e');
    }
  }

  void _abrirAnuncio(Aviso anuncio) {
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
      builder: (_) => _AnuncioExpandido(anuncio: anuncio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(
                hasLogo: false,
                hasReturn: true,
                text: 'Anúncios da Unidade',
              ),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      nomeUnidade,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Symbols.campaign, size: 22),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(child: _conteudo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregar,
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      );
    }

    if (anuncios.isEmpty) {
      return const Center(
        child: Text(
          'A unidade ainda não publicou anúncios.',
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: anuncios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final anuncio = anuncios[index];

        return _CardAnuncio(
          anuncio: anuncio,
          onTap: () => _abrirAnuncio(anuncio),
        );
      },
    );
  }
}

// ============================================================
// CARD DA LISTA
// ============================================================

class _CardAnuncio extends StatelessWidget {
  final Aviso anuncio;
  final VoidCallback onTap;

  const _CardAnuncio({required this.anuncio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        color: appColors.mutedBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        anuncio.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tempoDecorrido(anuncio.data),
                      style: const TextStyle(fontSize: 9),
                    ),
                    if (anuncio.fixado) ...[
                      const SizedBox(width: 6),
                      const Icon(Symbols.push_pin, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  anuncio.texto,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, height: 1.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// POPUP (ANÚNCIO EXPANDIDO)
// ============================================================

class _AnuncioExpandido extends StatelessWidget {
  final Aviso anuncio;

  const _AnuncioExpandido({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final temImagem = (anuncio.imagem?.trim() ?? '').isNotEmpty;

    return Dialog(
      backgroundColor: scheme.surfaceContainerHighest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      anuncio.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Symbols.campaign, size: 20),
                  const Spacer(),
                  if (anuncio.fixado) const Icon(Symbols.push_pin, size: 16),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _dataCompleta(anuncio.data),
                style: const TextStyle(fontSize: 9),
              ),
              const SizedBox(height: 10),
              Text(
                anuncio.texto,
                style: const TextStyle(fontSize: 11, height: 1.3),
              ),
              if (temImagem) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.24),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 205 / 130,
                      child: Image.network(
                        anuncio.imagem!,
                        fit: BoxFit.cover,
                        // Foto que não carrega não pode fechar o diálogo.
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 130,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                    ),
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

// ============================================================
// FORMATADORES
// ============================================================

String _tempoDecorrido(DateTime data) {
  final dias = DateTime.now().difference(data).inDays;

  if (dias <= 0) return 'hoje';
  if (dias == 1) return 'há 1 dia';
  return 'há $dias dias';
}

String _dataCompleta(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');

  return '${dois(data.day)}/${dois(data.month)}/${data.year}, '
      '${dois(data.hour)}:${dois(data.minute)}';
}