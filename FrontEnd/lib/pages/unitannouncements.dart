import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/widgets/topbar.dart';

// ============================================================
// MODELO + MOCK (temporário, até existir na API)
// Quando o backend tiver o endpoint, mova a classe Anuncio para
// lib/models/anuncio.dart e os dados para um AnuncioService.
// ============================================================

class Anuncio {
  final int id;
  final String titulo;
  final String texto;
  final DateTime data;
  final bool fixado;
  final String? imagem;

  const Anuncio({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.data,
    this.fixado = false,
    this.imagem,
  });
}

class _AnunciosMock {
  static const String nomeUnidade = 'Unidade de Conservação';

  static const String _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Nunc commodo turpis leo, ut fringilla lorem posuere a. '
      'Mauris ut tellus in justo venenatis tristique efficitur sit amet metus.';

  static List<Anuncio> listar() {
    final agora = DateTime.now();

    return [
      Anuncio(
        id: 1,
        titulo: 'Anúncio fixado',
        texto: _lorem,
        data: agora.subtract(const Duration(days: 30)),
        fixado: true,
        imagem: 'assets/images/araraias.jpg',
      ),
      for (int i = 2; i <= 6; i++)
        Anuncio(
          id: i,
          titulo: 'Anúncio',
          texto: _lorem,
          data: agora.subtract(const Duration(days: 6)),
          // Só o primeiro da lista comum tem imagem, para testar os dois casos.
          imagem: i == 2 ? 'assets/images/araraias.jpg' : null,
        ),
    ];
  }
}

// ============================================================
// PÁGINA
// ============================================================

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  late final List<Anuncio> anuncios;

  @override
  void initState() {
    super.initState();

    anuncios = _AnunciosMock.listar();

    // Fixados sempre no topo; dentro de cada grupo, mais recentes primeiro.
    anuncios.sort((a, b) {
      if (a.fixado != b.fixado) return a.fixado ? -1 : 1;
      return b.data.compareTo(a.data);
    });
  }

  void _abrirAnuncio(Anuncio anuncio) {
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
                      _AnunciosMock.nomeUnidade,
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

              Expanded(
                child: ListView.separated(
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
// CARD DA LISTA
// ============================================================

class _CardAnuncio extends StatelessWidget {
  final Anuncio anuncio;
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
                    Text(
                      anuncio.titulo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tempoDecorrido(anuncio.data),
                      style: const TextStyle(fontSize: 9),
                    ),
                    const Spacer(),
                    if (anuncio.fixado) const Icon(Symbols.push_pin, size: 14),
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
  final Anuncio anuncio;

  const _AnuncioExpandido({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                  Text(
                    anuncio.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
              if (anuncio.imagem != null) ...[
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
                      child: Image.asset(anuncio.imagem!, fit: BoxFit.cover),
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
