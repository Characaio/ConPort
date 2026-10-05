import 'package:flutter/material.dart';
import 'package:conport/models/especie.dart';
import 'package:conport/services/especie_service.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/core/theme/app_theme.dart';

/// Espécies registradas na unidade.
///
/// Os dados vêm de `GET /unidade/{unidadeId}/especies?tipo=FAUNA|FLORA`; com a
/// API desligada o [EspecieMock] devolve a mesma lista.
class EcossistemaPage extends StatefulWidget {
  final int unidadeId;

  const EcossistemaPage({super.key, this.unidadeId = 1});

  @override
  State<EcossistemaPage> createState() => _EcossistemaPageState();
}

class _EcossistemaPageState extends State<EcossistemaPage> {
  final EspecieService _especieService = const EspecieService();

  List<Especie> fauna = [];
  List<Especie> flora = [];

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
      final lista = await Future.wait([
        _especieService.listar(widget.unidadeId, TipoEspecie.fauna),
        _especieService.listar(widget.unidadeId, TipoEspecie.flora),
      ]);

      if (!mounted) return;
      setState(() {
        fauna = lista[0];
        flora = lista[1];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Especie? especieSelecionada;

  bool gavetaAberta = false;

  // Distância usada para esconder a gaveta abaixo da tela.
  double deslocamentoGaveta = 385;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================
            // CONTEÚDO PRINCIPAL
            // ==========================================
            Column(
              children: [
                // TOPBAR FIXA
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Topbar(
                    hasLogo: false,
                    hasReturn: true,
                    text: 'Ecossistema',
                  ),
                ),

                // CONTEÚDO COM SCROLL
                Expanded(child: _conteudo()),
              ],
            ),

            // ==========================================
            // FUNDO ESCURO ATRÁS DA GAVETA
            // ==========================================
            if (gavetaAberta)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _fecharGaveta,
                  child: AnimatedOpacity(
                    duration: AppSettings.instance.duracao(
                      const Duration(milliseconds: 350),
                    ),
                    opacity: gavetaAberta ? 0.35 : 0,
                    child: Container(
                      color: colors.scrim.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),

            // ==========================================
            // GAVETA
            // ==========================================
            if (especieSelecionada != null)
              AnimatedPositioned(
                duration: AppSettings.instance.duracao(
                  const Duration(milliseconds: 450),
                ),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,

                // 0 = totalmente aberta
                // 385 = escondida
                bottom: -deslocamentoGaveta,

                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    // Permite arrastar a gaveta para baixo.
                    if (details.delta.dy > 0) {
                      setState(() {
                        deslocamentoGaveta =
                            (deslocamentoGaveta + details.delta.dy)
                                .clamp(0.0, 385.0)
                                .toDouble();
                      });
                    }
                  },
                  onVerticalDragEnd: (details) {
                    final velocidade = details.primaryVelocity ?? 0;

                    // Se arrastou bastante ou rapidamente para baixo,
                    // fecha a gaveta.
                    if (deslocamentoGaveta > 120 || velocidade > 700) {
                      _fecharGaveta();
                    } else {
                      // Caso contrário, volta para a posição aberta.
                      setState(() {
                        deslocamentoGaveta = 0;
                      });
                    }
                  },
                  child: _buildEspecieSelecionada(especieSelecionada!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CONTEÚDO
  // ==========================================

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

    if (fauna.isEmpty && flora.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'A unidade ainda não cadastrou espécies.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fauna.isNotEmpty)
            _buildCategoria(
              titulo: 'Fauna',
              icone: Icons.pets,
              especies: fauna,
            ),

          if (fauna.isNotEmpty && flora.isNotEmpty)
            const SizedBox(height: 28),

          if (flora.isNotEmpty)
            _buildCategoria(
              titulo: 'Flora',
              icone: Icons.park,
              especies: flora,
            ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORIA
  // ==========================================

  Widget _buildCategoria({
    required String titulo,
    required IconData icone,
    required List<Especie> especies,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 27, color: colors.onSurface),

            const SizedBox(width: 12),

            Text(
              titulo,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: especies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final especie = especies[index];

            return _buildCard(especie);
          },
        ),
      ],
    );
  }

  // ==========================================
  // CARD
  // ==========================================

  Widget _buildCard(Especie especie) {
    final colors = Theme.of(context).colorScheme;
    final bool selecionada = especieSelecionada == especie && gavetaAberta;

    return GestureDetector(
      onTap: () {
        _abrirGaveta(especie);
      },
      child: AnimatedContainer(
        duration: AppSettings.instance.duracao(
          const Duration(milliseconds: 150),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: selecionada
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _imagemDaEspecie(especie, context),

              // Gradiente escuro inferior
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colors.onSurface.withValues(alpha: 0.87),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 9,
                right: 7,
                bottom: 7,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        especie.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurface,
                      size: 27,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CONTEÚDO DA GAVETA
  // ==========================================

  Widget _buildEspecieSelecionada(Especie especie) {
    return Container(
      height: 385,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 10, 19, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C4734)
            : Color(0xFF5E7654),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 52,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            especie.nome,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            especie.nomeCientifico ?? '',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                especie.descricao ?? '',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 12.5,
                  height: 1.25,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 145,
              width: double.infinity,
              child: _imagemDaEspecie(especie, context),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ABRIR GAVETA
  // ==========================================

  void _abrirGaveta(Especie especie) {
    setState(() {
      especieSelecionada = especie;

      // Começa escondida.
      deslocamentoGaveta = 385;

      gavetaAberta = true;
    });

    // Depois que o widget entrar na árvore,
    // anima até a posição aberta.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        deslocamentoGaveta = 0;
      });
    });
  }

  // ==========================================
  // FECHAR GAVETA
  // ==========================================

  void _fecharGaveta() {
    setState(() {
      deslocamentoGaveta = 385;
    });

    // Espera a animação terminar antes de
    // remover o conteúdo da gaveta.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        gavetaAberta = false;
        especieSelecionada = null;
        deslocamentoGaveta = 385;
      });
    });
  }
}

// ==========================================
// MODELO
// ==========================================

/// Foto da espécie: a que veio da API, ou um placeholder quando a espécie
/// não tem foto cadastrada ou a foto não carrega.
Widget _imagemDaEspecie(Especie especie, BuildContext context) {
  final url = especie.imagem?.trim() ?? '';

  final semFoto = Container(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    child: const Icon(Icons.image_not_supported, size: 40),
  );

  if (url.isEmpty) return semFoto;

  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => semFoto,
  );
}
