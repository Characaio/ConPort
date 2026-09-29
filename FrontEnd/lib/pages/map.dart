import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:async';
import 'package:conport/widgets/homemap.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final GlobalKey<HomeMapState> _mapKey = GlobalKey<HomeMapState>();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  List<LocalSugestao> _sugestoes = [];

  bool _pesquisando = false;

  // Controla a posição da gaveta.
  // 0.12 = fechada
  // 0.75 = aberta
  double _drawerSize = 0.12;

  double _dragStartSize = 0.12;

  void _buscarSugestoes(String texto) {
    _searchDebounce?.cancel();

    if (texto.trim().isEmpty) {
      setState(() {
        _sugestoes = [];
        _pesquisando = false;
      });

      return;
    }

    setState(() {
      _pesquisando = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final resultados = await _mapKey.currentState?.buscarSugestoes(texto);

      if (!mounted) {
        return;
      }

      setState(() {
        _sugestoes = resultados ?? [];
        _pesquisando = false;
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

  void _alternarGaveta() {
    if (_drawerSize > 0.4) {
      _fecharGaveta();
    } else {
      _abrirGaveta();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: Stack(
          children: [
            // ============================================================
            // MAPA
            // ============================================================
            Positioned.fill(child: HomeMap(key: _mapKey)),

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
                  color: const Color(0xFFD8C7B8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
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
                  color: const Color(0xFFD8C7B8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
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
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.black54),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.black54,
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
                  color: const Color(0xFFE8E0D8),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _sugestoes.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.08),
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
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 19,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sugestao.nome,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
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
                  color: const Color(0xFFD8C7B8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    await _mapKey.currentState?.centralizarLocalizacao();
                  },
                  icon: const Icon(
                    Icons.my_location,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ============================================================
            // GAVETA
            // ============================================================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * _drawerSize,
              child: Material(
                elevation: 12,
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8E0D8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ==================================================
                      // ALÇA ARRASTÁVEL
                      // ==================================================
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: (_) {
                          _dragStartSize = _drawerSize;
                        },
                        onVerticalDragUpdate: (details) {
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;

                          final delta = -details.delta.dy / screenHeight;

                          setState(() {
                            _drawerSize = (_dragStartSize + delta).clamp(
                              0.12,
                              0.75,
                            );
                          });
                        },
                        onVerticalDragEnd: (details) {
                          final velocity = details.primaryVelocity ?? 0;

                          // Arrastou para cima
                          if (velocity < -300) {
                            _abrirGaveta();
                            return;
                          }

                          // Arrastou para baixo
                          if (velocity > 300) {
                            _fecharGaveta();
                            return;
                          }

                          // Soltou no meio:
                          // decide pelo ponto onde ficou.
                          if (_drawerSize >= 0.4) {
                            _abrirGaveta();
                          } else {
                            _fecharGaveta();
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // CONTEÚDO DA GAVETA
                      // ==================================================
                      Expanded(
                        child: ListView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          children: [
                            // TÍTULO
                            const Text(
                              'Unidade de Conservação',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Parque Estadual',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),

                            // LOCALIZAÇÃO
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 17,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Localização da unidade',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // TELEFONE
                            Row(
                              children: const [
                                Icon(
                                  Icons.phone,
                                  size: 17,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Telefone: (19) 3456-7890',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // HORÁRIO
                            Row(
                              children: const [
                                Icon(
                                  Icons.access_time,
                                  size: 17,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Aberto hoje',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 26),

                            // DIVISÓRIA
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.black.withValues(alpha: 0.10),
                            ),

                            const SizedBox(height: 12),

                            // DESCRIÇÃO
                            const Text(
                              'Área destinada à preservação da fauna e flora, '
                              'com grande importância para a conservação '
                              'do ecossistema.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // =================================================
                            // AVISO
                            // =================================================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0E4D5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Atenção: respeite as regras '
                                      'de preservação e evite deixar '
                                      'resíduos no local.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // =================================================
                            // BOTOES
                            // =================================================
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
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
                                        backgroundColor: const Color(
                                          0xFF5E7654,
                                        ),
                                        foregroundColor: const Color(
                                          0xFFE8E4DC,
                                        ),
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
                                      onPressed: () {},
                                      icon: const Icon(
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
                                        backgroundColor: const Color(
                                          0xFF5E7654,
                                        ),
                                        foregroundColor: const Color(
                                          0xFFE8E4DC,
                                        ),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: double.infinity,
                                height: 250,
                                child: Image.asset(
                                  'assets/images/araraias.jpg',
                                  fit: BoxFit.cover,
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

            // ============================================================
            // BOTÃO PARA ABRIR/FECHAR A GAVETA
            // ============================================================
            //
            // Fica escondido quando a gaveta está aberta.
            //
            if (_drawerSize < 0.4)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _alternarGaveta,
                  child: const SizedBox(height: 55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
