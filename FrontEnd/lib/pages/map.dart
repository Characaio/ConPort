import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:async';
import 'package:conport/widgets/mapembed.dart';
import 'package:conport/models/unidade_mapa.dart';
import 'package:conport/services/map_service.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final GlobalKey<MapEmbedState> _mapKey = GlobalKey<MapEmbedState>();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  List<LocalSugestao> _sugestoes = [];

  // Controla a posição da gaveta.
  // 0.12 = fechada
  // 0.75 = aberta
  double _drawerSize = 0.12;

  double _dragStartSize = 0.12;

  final MapService _mapService = const MapService();

  UnidadeMapa? _unidade;

  @override
  void initState() {
    super.initState();
    _carregarUnidade();
  }

  Future<void> _carregarUnidade() async {
    try {
      final unidade = await _mapService.buscarUnidade(1);

      if (!mounted) return;

      setState(() {
        _unidade = unidade;
      });
    } catch (e) {
      debugPrint('Erro ao carregar unidade: $e');
    }
  }

  void _buscarSugestoes(String texto) {
    _searchDebounce?.cancel();

    if (texto.trim().isEmpty) {
      setState(() {
        _sugestoes = [];
      });

      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final resultados = await _mapKey.currentState?.buscarSugestoes(texto);

      if (!mounted) {
        return;
      }

      setState(() {
        _sugestoes = resultados ?? [];
      });
    });
  }

  void _selecionarSugestao(LocalSugestao sugestao) {
    _searchController.text = sugestao.nome;

    setState(() {
      _sugestoes = [];
    });

    _mapKey.currentState?.irParaLocal(sugestao);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _abrirGaveta() {
    setState(() {
      _drawerSize = 0.75;
    });
  }

  void _fecharGaveta() {
    setState(() {
      _drawerSize = 0.12;
    });
  }

  void _abrirGavetaSeFechada() {
    if (_drawerSize < 0.4) {
      _abrirGaveta();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // ============================================================
            // MAPA
            // ============================================================
            Positioned.fill(child: MapEmbed(key: _mapKey)),

            // ============================================================
            // BOTÃO VOLTAR
            // ============================================================
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.18),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ============================================================
            // BARRA DE PESQUISA
            // ============================================================
            Positioned(
              top: 12,
              left: 62,
              right: 12,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.18),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: _buscarSugestoes,
                  onSubmitted: (value) {
                    _searchDebounce?.cancel();

                    setState(() {
                      _sugestoes = [];
                    });

                    _mapKey.currentState?.pesquisarLocal(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Pesquisar...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            if (_sugestoes.isNotEmpty)
              Positioned(
                top: 66,
                left: 62,
                right: 12,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: colors.surfaceContainerHighest,
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _sugestoes.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: colors.outline.withValues(alpha: 0.18),
                      ),
                      itemBuilder: (context, index) {
                        final sugestao = _sugestoes[index];

                        return InkWell(
                          onTap: () {
                            _selecionarSugestao(sugestao);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 19,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sugestao.nome,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            // ============================================================
            // BOTÃO CENTRALIZAR LOCALIZAÇÃO
            // ============================================================
            //
            // Fica sempre acima da gaveta.
            //
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * _drawerSize + 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.18),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    await _mapKey.currentState?.centralizarLocalizacao();
                  },
                  icon: Icon(
                    Icons.my_location,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ============================================================
            // FUNDO ESCURO ATRÁS DA GAVETA
            // ============================================================
            //
            // Mesmo comportamento da gaveta da página de ecossistema:
            // escurece o mapa e, ao tocar fora, fecha a gaveta.
            //
            // O IgnorePointer garante que, com a gaveta fechada,
            // o mapa continue interativo.
            //
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _drawerSize < 0.4,
                child: GestureDetector(
                  onTap: _fecharGaveta,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _drawerSize >= 0.4 ? 1 : 0,
                    child: Container(
                      color: colors.scrim.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

            // ============================================================
            // GAVETA
            // ============================================================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * _drawerSize,

              // O arrasto vale para toda a superfície da gaveta,
              // e não apenas para a alça.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _abrirGavetaSeFechada,
                onVerticalDragStart: (_) {
                  _dragStartSize = _drawerSize;
                },
                onVerticalDragUpdate: (details) {
                  final screenHeight = MediaQuery.of(context).size.height;

                  final delta = -details.delta.dy / screenHeight;

                  setState(() {
                    _drawerSize = (_dragStartSize + delta).clamp(0.12, 0.75);
                  });
                },
                onVerticalDragEnd: (details) {
                  final velocidade = details.primaryVelocity ?? 0;

                  // Arrastou para cima com força.
                  if (velocidade < -700) {
                    _abrirGaveta();
                    return;
                  }

                  // Arrastou para baixo com força.
                  if (velocidade > 700) {
                    _fecharGaveta();
                    return;
                  }

                  // Soltou sem impulso:
                  // decide pelo ponto onde ficou.
                  if (_drawerSize >= 0.4) {
                    _abrirGaveta();
                  } else {
                    _fecharGaveta();
                  }
                },
                child: Material(
                  elevation: 12,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2E2A25)
                          : Color(0xFFE8E0D8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // ==================================================
                        // ALÇA
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colors.outline,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // CONTEÚDO DA GAVETA
                        // ==================================================
                        Expanded(
                          child: ListView(
                            // Enquanto a gaveta não está totalmente aberta, o
                            // arrasto precisa chegar até ela. Sem isso, a lista
                            // engole o gesto e a gaveta fica difícil de mover.
                            // Com a gaveta aberta, a lista volta a rolar.
                            physics: _drawerSize >= 0.75
                                ? const ClampingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            children: [
                              // TÍTULO
                              Text(
                                _unidade?.nome ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _unidade?.tipo ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),

                              // LOCALIZAÇÃO
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 17,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _unidade?.local ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // TELEFONE
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 17,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Telefone: ${_unidade?.telefone ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // HORÁRIO
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 17,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    _unidade?.horario ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 26),

                              // DIVISÓRIA
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: colors.outline.withValues(alpha: 0.20),
                              ),

                              const SizedBox(height: 12),

                              // DESCRIÇÃO
                              Text(
                                _unidade?.descricao ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // =================================================
                              // AVISO
                              // =================================================
                              if (_unidade?.aviso != null) ...[
                                Material(
                                  color: colors.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      PageLoader.go(
                                        context,
                                        PageLoader.anuncios,
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 18,
                                            color: colors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _unidade!.aviso!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colors.onSurfaceVariant,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ], // =================================================
                              // BOTOES
                              // =================================================
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          PageLoader.go(
                                            context,
                                            PageLoader.ecossistema,
                                          );
                                        },
                                        icon: Icon(
                                          Symbols.emoji_nature,
                                          size: 20,
                                          weight: 12,
                                        ),
                                        label: const Text(
                                          'Ecossistema',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              appColors.accentGreen,
                                          foregroundColor: appColors.onAccent,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          PageLoader.go(
                                            context,
                                            PageLoader.unit,
                                          );
                                        },
                                        icon: Icon(
                                          Symbols.globe_2_question,
                                          size: 20,
                                          weight: 12,
                                        ),
                                        label: const Text(
                                          'Saiba mais...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              appColors.accentGreen,
                                          foregroundColor: appColors.onAccent,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // =================================================
                              // IMAGEM
                              // =================================================
                             if (_unidade != null && _unidade!.imagens.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: Image.network(
                                      _unidade!.imagens.first,
                                      fit: BoxFit.cover,
                                      // Foto que não carrega não pode derrubar a gaveta.
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
