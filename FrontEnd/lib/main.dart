import 'package:flutter/material.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/services/auth_service.dart';

/// Chave global para conseguir navegar de fora de um widget.
///
/// É o que permite reagir a uma sessão derrubada pelo servidor no meio do uso:
/// a tela que estava aberta não tem como navegar sozinha, então quem faz isso
/// é o [Conport], ouvindo a [AuthSession].
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const Abertura());
}

/// Primeira tela: segura o app enquanto o token guardado é conferido.
///
/// Sem essa espera, o app abriria na tela de acesso por um instante e só depois
/// saltaria para a home de quem já estava logado — e pior, com [usuario] vazio
/// no meio do caminho, o que quebra a primeira tela que lê a sessão.
class Abertura extends StatefulWidget {
  const Abertura({super.key});

  @override
  State<Abertura> createState() => _AberturaState();
}

class _AberturaState extends State<Abertura> {
  @override
  void initState() {
    super.initState();

    _restaurar();
  }

  /// Restaura a sessão guardada e **sempre** abre o app em seguida.
  ///
  /// [AuthSession.restaurar] já tem limite de tempo e engole as próprias
  /// exceções; o `finally` é a garantia por cima: nenhum caminho — cofre que
  /// nunca responde, rede fora, erro inesperado — pode deixar esta tela de
  /// carregamento na frente para sempre. O desfecho ruim aceitável é abrir sem
  /// sessão e deixar a pessoa entrar de novo.
  Future<void> _restaurar() async {
    try {
      await AuthSession.instance.restaurar(sonda: AuthService.validarToken);
    } catch (e) {
      debugPrint('ABERTURA: não deu para restaurar a sessão: $e');
    } finally {
      if (mounted) runApp(const Conport());
    }
  }

  @override
  Widget build(BuildContext context) {
    const cor = Color(0xFF5E7654);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: cor,
        body: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class Conport extends StatefulWidget {
  const Conport({super.key});

  @override
  State<Conport> createState() => _ConportState();
}

class _ConportState extends State<Conport> {
  final settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    settings.addListener(_settingsChanged);
    AuthSession.instance.addListener(_sessaoMudou);
  }

  @override
  void dispose() {
    settings.removeListener(_settingsChanged);
    AuthSession.instance.removeListener(_sessaoMudou);
    super.dispose();
  }

  void _settingsChanged() {
    if (mounted) setState(() {});
  }

  /// Token recusado no meio do uso: volta para a tela de acesso, tirando a
  /// pessoa do meio de qualquer tela que dependesse da conta.
  ///
  /// O aviso vem do `rootNavigatorContext` porque o `ScaffoldMessenger` da tela
  /// atual pode estar prestes a sumir junto com ela.
  void _sessaoMudou() {
    if (!mounted) return;

    final sessao = AuthSession.instance;

    if (sessao.expirada) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        PageLoader.welcome,
        (rota) => false,
      );

      final contexto = navigatorKey.currentContext;

      if (contexto != null) {
        ScaffoldMessenger.of(
          contexto,
        ).showSnackBar(const SnackBar(
          content: Text('Sua sessão expirou. Entre de novo.'),
        ));
      }

      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Conport',
      theme: AppTheme.lightThemeFor(
        useMaterial3: settings.useMaterial3,
        highContrast: settings.highContrast,
      ),
      darkTheme: AppTheme.darkThemeFor(
        useMaterial3: settings.useMaterial3,
        highContrast: settings.highContrast,
      ),
      themeMode: settings.themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      // Sem sessão, o app começa na tela intermediária de acesso. A sessão já
      // foi restaurada aqui: [initialRoute] é lido uma vez só.
      initialRoute: AuthSession.instance.temSessao
          ? PageLoader.home
          : PageLoader.welcome,
      onGenerateRoute: PageLoader.generateRoute,
    );
  }
}