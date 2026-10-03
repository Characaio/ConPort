import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/widgets/topbar.dart';

class EducacaoPage extends StatelessWidget {
  const EducacaoPage({super.key});

  static const List<_VideoEducativo> videos = [
    _VideoEducativo(
      titulo: 'O que é biodiversidade?',
      resumo:
          'Entenda o que significa biodiversidade e por que a variedade de espécies é importante para o equilíbrio dos ecossistemas.',
      buscaYoutube: 'biodiversidade o que é educação ambiental',
      imagem:
          'https://upload.wikimedia.org/wikipedia/commons/3/3d/Tropical_rainforest_in_Sri_Lanka.jpg',
    ),
    _VideoEducativo(
      titulo: 'Por que proteger as florestas?',
      resumo:
          'Conheça alguns dos serviços ambientais das florestas e como a conservação dos ambientes naturais ajuda diferentes espécies.',
      buscaYoutube: 'importância das florestas educação ambiental',
      imagem:
          'https://upload.wikimedia.org/wikipedia/commons/b/b9/The_tree_in_forest.jpg',
    ),
    _VideoEducativo(
      titulo: 'Unidades de Conservação',
      resumo:
          'Aprenda de forma simples como as unidades de conservação ajudam a proteger a natureza e a biodiversidade.',
      buscaYoutube: 'unidades de conservação educação ambiental',
      imagem:
          'https://upload.wikimedia.org/wikipedia/commons/7/71/Capybaracropped.jpg',
    ),
  ];

  static const List<_TextoEducativo> textos = [
    _TextoEducativo(
      titulo: 'Observe antes de agir',
      texto:
          'Ao visitar uma área natural, mantenha distância dos animais, evite retirar plantas e respeite as orientações da unidade de conservação.',
      icone: Symbols.visibility,
    ),
    _TextoEducativo(
      titulo: 'Pequenas atitudes ajudam',
      texto:
          'Reduzir resíduos, economizar água, evitar desperdícios e cuidar dos espaços naturais são atitudes que contribuem para a conservação.',
      icone: Symbols.eco,
    ),
    _TextoEducativo(
      titulo: 'Um bom report faz diferença',
      texto:
          'Ao registrar uma ocorrência, procure informar o local, descrever o que observou e, quando possível, adicionar uma fotografia que ajude na identificação.',
      icone: Symbols.flag,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Topbar(
              hasLogo: false,
              hasReturn: true,
              text: 'Aprender',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aprenda sobre conservação',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Conteúdos rápidos para conhecer melhor a biodiversidade e ajudar a proteger o meio ambiente.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Icon(
                          Symbols.play_circle,
                          color: appColors.accentGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Vídeos educativos',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...videos.map(
                      (video) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _VideoCard(video: video),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Symbols.menu_book,
                          color: appColors.accentBrown,
                          size: 27,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Leia e descubra',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...textos.map(
                      (texto) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TextoCard(texto: texto),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _VideoEducativo video;

  const _VideoCard({
    required this.video,
  });

  Future<void> _abrirVideo() async {
    final query = Uri.encodeQueryComponent(
      video.buscaYoutube,
    );

    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=$query',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: _abrirVideo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 175,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.imagem,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: colors.surfaceContainerHigh,
                      );
                    },
                  ),

                  Container(
                    color: colors.scrim.withValues(
                      alpha: 0.25,
                    ),
                  ),

                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(
                          alpha: 0.9,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.play_arrow,
                        size: 35,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.titulo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    video.resumo,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Assistir',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Symbols.open_in_new,
                        size: 18,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextoCard extends StatelessWidget {
  final _TextoEducativo texto;

  const _TextoCard({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.55,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: appColors.accentGreen.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              texto.icone,
              color: appColors.accentGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texto.titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  texto.texto,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoEducativo {
  final String titulo;
  final String resumo;
  final String buscaYoutube;
  final String imagem;

  const _VideoEducativo({
    required this.titulo,
    required this.resumo,
    required this.buscaYoutube,
    required this.imagem,
  });
}

class _TextoEducativo {
  final String titulo;
  final String texto;
  final IconData icone;

  const _TextoEducativo({
    required this.titulo,
    required this.texto,
    required this.icone,
  });
}

