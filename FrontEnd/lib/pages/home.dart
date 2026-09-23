import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/widgets/homemap.dart';
import 'package:conport/widgets/unidadeindicador.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/widgets/weekly_missions.dart';

class HomeData {
  final String nome;
  final String horario;
  final String telefone;
  final double integridade;
  final double conectividadeEcologica;
  final String fiscalizacao;
  final String diversidade;
  final String poluicao;
  final String preservacao;
  final int incidentes;
  final String tipoUnidade;

  HomeData({
    required this.nome,
    required this.horario,
    required this.telefone,
    required this.integridade,
    required this.conectividadeEcologica,
    required this.fiscalizacao,
    required this.diversidade,
    required this.poluicao,
    required this.preservacao,
    required this.incidentes,
    required this.tipoUnidade,
  });
}

final HomeData homeMock = HomeData(
  nome: "Unidade de Conservação X",
  horario: "Aberto até às 21:00",
  telefone: "(19) 99999-9999",
  integridade: 67.5,
  conectividadeEcologica: 42,
  fiscalizacao: "Alta",
  diversidade: "Alta",
  poluicao: "Baixa",
  preservacao: "Alta",
  incidentes: 7,
  tipoUnidade: "Unidade de Pesquisa",
);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState(unidade: homeMock);
}

class _HomeState extends State<Home> {
  final HomeData unidade;

  _HomeState({required this.unidade});
  bool _missionsOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Topbar(hasLogo: true, hasReturn: false, text: ""),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: colors.primary, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(height: 400, child: HomeMap()),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  spacing: 12.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UnidadeIndicador(
                                      simbolo: Symbols.explore,
                                      texto: unidade.nome,
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.schedule,
                                      texto: unidade.horario,
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.call,
                                      texto: unidade.telefone,
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.heart_check,
                                      texto:
                                          "Integridade: ${unidade.integridade}%",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.sync_alt,
                                      texto:
                                          "Conectividade Ecológica: ${unidade.conectividadeEcologica}%",
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12.0,
                                  children: [
                                    UnidadeIndicador(
                                      simbolo: Symbols.siren,
                                      texto:
                                          "Fiscalização ${unidade.fiscalizacao}",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.nest_eco_leaf,
                                      texto:
                                          "Diversidade: ${unidade.diversidade}",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.cloud_alert,
                                      texto: "Poluição: ${unidade.poluicao}",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.forest,
                                      texto:
                                          "Preservação: ${unidade.preservacao}",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.emergency_home,
                                      texto:
                                          "Incidentes: ${unidade.incidentes}",
                                    ),
                                    UnidadeIndicador(
                                      simbolo: Symbols.local_library,
                                      texto: unidade.tipoUnidade,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 24.0,
                  ),
                  child: Row(
                    spacing: 24.0,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            PageLoader.go(context, PageLoader.reports);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.surface,
                            elevation: 5,
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Symbols.flag, size: 28.0),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Reportar incidente",
                                    style: const TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            PageLoader.go(context, PageLoader.unit);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.surface,
                            elevation: 5,
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Symbols.question_mark, size: 28.0),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Mais sobre a unidade",
                                    style: const TextStyle(fontSize: 16.0),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMissionDropup(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionDropup(ColorScheme colors) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _missionsOpen = !_missionsOpen;
              });
            },
            child: Container(
              width: 160,
              height: 34,
              decoration: BoxDecoration(
                color: colors.tertiary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(
                !_missionsOpen
                    ? Symbols.keyboard_arrow_up
                    : Symbols.keyboard_arrow_down,
                color: colors.onPrimary,
                size: 24,
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _missionsOpen
                ? WeeklyMissions(userLevel: 12, onRewardsTap: () {})
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
