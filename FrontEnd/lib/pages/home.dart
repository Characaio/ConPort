import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/widgets/homemap.dart';
import 'package:conport/widgets/unidadeindicador.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Topbar(),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.green, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(height: 400, child: HomeMap()),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    height: 300,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 12.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UnidadeIndicador(
                                  simbolo: Symbols.explore,
                                  texto: 'Nome',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.schedule,
                                  texto: 'Aberto até às 00:00',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.call,
                                  texto: '(99) 99999-9999',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.heart_check,
                                  texto: 'Integridade: 00%',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.sync_alt,
                                  texto: 'Conectividade Ecológica: 00%',
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
                                  texto: 'Fiscalização: Alta',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.nest_eco_leaf,
                                  texto: 'Diversidade: Alta',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.cloud_alert,
                                  texto: 'Poluição: Baixa',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.forest,
                                  texto: 'Preservação: Alta',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.emergency_home,
                                  texto: 'Incidentes: 0',
                                ),
                                UnidadeIndicador(
                                  simbolo: Symbols.local_library,
                                  texto: 'Unidade de Pesquisa',
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
          ],
        ),
      ),
    );
  }
}
