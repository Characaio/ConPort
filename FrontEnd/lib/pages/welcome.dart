import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/widgets/auth_ui.dart';

/// Tela intermediária do acesso: o usuário escolhe entre entrar, criar uma
/// conta ou explorar sem conta.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _entrar(BuildContext context) =>
      PageLoader.go(context, PageLoader.login);

  void _criarConta(BuildContext context) =>
      PageLoader.go(context, PageLoader.register);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image(
                      image: AssetImage('assets/images/ConportLogo.png'),
                      width: 96,
                      height: 96,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ConPort',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitoramento ambiental da sua Unidade de Conservação.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Entre na sua conta ou crie uma nova para acompanhar '
                          'seus reports, missões e recompensas.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        BotaoAuth(
                          texto: 'Entrar',
                          icone: Symbols.login,
                          corDeFundo: appColors.accentGreen,
                          onPressed: () => _entrar(context),
                        ),
                        const SizedBox(height: 10),
                        BotaoAuth(
                          texto: 'Criar conta',
                          icone: Symbols.person_add,
                          corDeFundo: appColors.accentBrown,
                          onPressed: () => _criarConta(context),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (!AppConfig.usarApi) ...[
                    const SizedBox(height: 16),
                    const Center(child: SeloModoDemo()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
