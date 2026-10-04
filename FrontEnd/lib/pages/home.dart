import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';

import 'package:conport/pages/avistamento.dart';

import 'package:conport/widgets/home/footer.dart';
import 'package:conport/widgets/home/homecard.dart';
import 'package:conport/widgets/mapembed.dart';
import 'package:conport/widgets/topbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // Visitantes não têm nome de conta.
    final nome = AuthSession.instance.usuario?.nome ?? 'Visitante';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.0,
              children: [
                Topbar(
                  hasLogo: true,
                  hasReturn: false,
                  text: '',
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 1,
                  children: [
                    const Text(
                      'Olá,',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '$nome!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // ========================================================
                // MAPA
                // ========================================================

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: colors.surfaceContainerLowest,
                    boxShadow: [
                      BoxShadow(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
                                    begin: const Alignment(0, 0.4),
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      colors.scrim.withValues(alpha: 0.5),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Mapa',
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

                const SizedBox(height: 16),

                // ========================================================
                // CARDS PRINCIPAIS
                // ========================================================

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
                              text: 'Criar Report',
                              color: appColors.accentBrown,
                              pagina: PageLoader.criarreport,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            flex: 4,
                            child: Column(
                              spacing: 6,
                              children: [
                                // ==================================================
                                // ENVIAR AVISTAMENTO
                                // ==================================================

                                Expanded(
                                  child: HomeCard(
                                    icon: Symbols.remove_red_eye,
                                    text: 'Enviar Avistamento',
                                    color: appColors.accentGreen,
                                    onTap: () {
                                      final usuario =
                                          AuthSession.instance.usuario;

                                      if (usuario == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Você precisa estar logado para enviar um avistamento.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Sem id de usuário: quem registra é a
                                      // pessoa do token, no servidor.
                                      AvistamentoPage.iniciar(
                                        context,
                                        unidadeId: 1,
                                      );
                                    },
                                  ),
                                ),

                                // ==================================================
                                // AMIGOS
                                // ==================================================

                                Expanded(
                                  child: HomeCard(
                                    icon: Symbols.people,
                                    text: 'Seus Amigos',
                                    color: appColors.accentSalmon,
                                    pagina: PageLoader.friends,
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

                const SizedBox(height: 4),

                const Center(
                  child: SizedBox(
                    width: 150,
                    child: Divider(),
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================================
                // TRILHA
                // ========================================================

                const Text(
                  'Continue sua Trilha',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                          color: colors.surfaceContainerLowest,
                        ),

                        Icon(
                          Symbols.play_circle,
                          size: 64,
                          color: colors.onSurface,
                        ),

                        Positioned(
                          left: 16,
                          bottom: 12,
                          child: Text(
                            'Continue assistindo',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                            ),
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
      ),

      bottomNavigationBar: const SafeArea(
        top: false,
        child: Footer(),
      ),
    );
  }
}
