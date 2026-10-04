import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conport/core/theme/app_theme.dart';

/// Dicas e vídeos que ajudam a escrever um bom report de cada tipo.
///
/// Aparece na tela de criação, logo abaixo da escolha do tipo: quem ainda não
/// sabe o que escrever tem algo para consultar ali mesmo.
class DicasDoTipo extends StatelessWidget {
  /// Tipo do report, no mesmo formato enviado ao backend (QUEIMADA, ...).
  final String tipo;

  const DicasDoTipo({super.key, required this.tipo});

  /// Dicas por tipo. Um tipo sem entrada simply não mostra a seção.
  static const Map<String, _Conteudo> _porTipo = {
    'QUEIMADA': _Conteudo(
      resumo:
          'Descreva onde o fogo começou, se ainda está ativo e o que você fez para tentar conter.',
      dica: 'Não se aproxime de uma queimada ativa. O report serve para avisar, não para apagar o fogo.',
      video: _Video(
        titulo: 'Como agir diante de uma queimada',
        busca: 'queimada o que fazer incêndio ambiental',
        imagem:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Forest_fire_in_Canada.jpg/640px-Forest_fire_in_Canada.jpg',
      ),
    ),
    'ANIMAL_FERIDO': _Conteudo(
      resumo:
          'Informe a espécie se conseguir, onde o animal está e se ele ainda se move.',
      dica: 'Mantenha distância. Não tente mover o animal sozinho.',
      video: _Video(
        titulo: 'O que fazer com um animal ferido',
        busca: 'animal ferido o que fazer resgate fauna',
        imagem:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Vet_injured_bird.jpg/640px-Vet_injured_bird.jpg',
      ),
    ),
    'ANIMAL_EXOTICO': _Conteudo(
      resumo:
          'Descreva o tamanho do animal, de onde ele veio e por onde anda.',
      dica: 'Não se aproxime. Espécies exóticas têm comportamento imprevisível e podem ser perigosas.',
      video: _Video(
        titulo: 'Espécies exóticas invasoras',
        busca: 'espécies exóticas invasoras o que são',
        imagem:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Red_fox.jpg/640px-Red_fox.jpg',
      ),
    ),
    'POLUICAO': _Conteudo(
      resumo:
          'Indique o que está sendo descartado, o tamanho do problema e se a poluição continua.',
      dica: 'Fotografe de longe e cite o ponto de referência mais próximo.',
      video: _Video(
        titulo: 'Poluição: o que é e como evitar',
        busca: 'poluição ambiental o que é como reduzir',
        imagem:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Litter_in_a_river.jpg/640px-Litter_in_a_river.jpg',
      ),
    ),
    'DESMATAMENTO': _Conteudo(
      resumo:
          'Conte quantas árvores caíram e se há corte de madeira ou terreno sendo preparado.',
      dica: 'Registre a área sem entrar na propriedade.',
      video: _Video(
        titulo: 'Por que preservar as florestas',
        busca: 'desmatamento causas consequências',
        imagem:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/The_tree_in_forest.jpg/640px-The_tree_in_forest.jpg',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final conteudo = _porTipo[tipo.toUpperCase()];

    if (conteudo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como relatar esse tipo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          conteudo.resumo,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        _CardDica(texto: conteudo.dica),
        const SizedBox(height: 14),
        _CardVideo(video: conteudo.video),
      ],
    );
  }
}

class _CardDica extends StatelessWidget {
  final String texto;

  const _CardDica({required this.texto});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.accentGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.lightbulb, size: 18, color: appColors.onAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 12, color: appColors.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de vídeo que abre uma busca no YouTube, igual ao da tela de Educação.
class _CardVideo extends StatelessWidget {
  final _Video video;

  const _CardVideo({required this.video});

  Future<void> _abrirVideo(BuildContext context) async {
    final query = Uri.encodeQueryComponent(video.busca);

    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=$query',
    );

    final abriu = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
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
        onTap: () => _abrirVideo(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.imagem,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(color: colors.surfaceContainerHigh);
                    },
                  ),
                  Container(
                    color: colors.scrim.withValues(alpha: 0.25),
                  ),
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.play_arrow,
                        size: 30,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      video.titulo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    'Assistir',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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

class _Conteudo {
  final String resumo;
  final String dica;
  final _Video video;

  const _Conteudo({
    required this.resumo,
    required this.dica,
    required this.video,
  });
}

class _Video {
  final String titulo;
  final String busca;
  final String imagem;

  const _Video({
    required this.titulo,
    required this.busca,
    required this.imagem,
  });
}