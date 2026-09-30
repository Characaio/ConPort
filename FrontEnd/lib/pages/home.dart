import 'package:conport/widgets/home/footer.dart';
import 'package:conport/widgets/mapembed.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/widgets/home/homecard.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              Topbar(hasLogo: true, hasReturn: false, text: ''),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 1,
                children: [
                  Text("Olá,", style: TextStyle(fontSize: 20)),
                  Text(
                    "Username!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      PageLoader.go(context, PageLoader.map);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(
                        height: 270,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MapEmbed(),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0, 0.4),
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Mapa",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colors.surface,
                                    ),
                                  ),
                                  Icon(
                                    Symbols.keyboard_arrow_right_rounded,
                                    weight: 300,
                                    color: colors.surface,
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

              SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: Row(
                      spacing: 6,
                      children: [
                        Expanded(
                          flex: 5,
                          child: HomeCard(
                            icon: Symbols.flag,
                            text: "Criar Report",
                            color: Color(0xFF766057),
                            pagina: PageLoader.criarreport,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 4,
                          child: Column(
                            spacing: 6,
                            children: [
                              Expanded(
                                child: HomeCard(
                                  icon: Symbols.remove_red_eye,
                                  text: "Enviar Avistamento",
                                  color: Color(0xFF597D59),
                                  pagina: "placeholder avistamento",
                                ),
                              ),

                              const SizedBox(height: 8),

                              Expanded(
                                child: HomeCard(
                                  icon: Symbols.people,
                                  text: "Seus Amigos",
                                  color: Color(0xFFC3917C),
                                  pagina: "placeholder amigos",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 4),
              Center(child: SizedBox(width: 150, child: Divider())),
              const SizedBox(height: 16),

              Text(
                "Continue sua Trilha",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Mock do vídeo
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black87,
                      ),

                      Icon(Symbols.play_circle, size: 64, color: Colors.white),

                      Positioned(
                        left: 16,
                        bottom: 12,
                        child: Text(
                          "Continue assistindo",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
