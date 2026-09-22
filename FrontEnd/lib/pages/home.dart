import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/widgets/homemap.dart';
import 'package:conport/widgets/unidadeindicador.dart';
import 'package:conport/core/navigation/page_loader.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Topbar(hasLogo: true, hasReturn: false, text: ""),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Expanded(
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
          ],
        ),
      ),
    );
  }
}
