import 'package:flutter/material.dart';
import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';

void main() {
  runApp(const Conport());
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
  }

  @override
  void dispose() {
    settings.removeListener(_settingsChanged);
    super.dispose();
  }

  void _settingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // Sem sessão, o app começa na tela intermediária de acesso.
      initialRoute: AuthSession.instance.temSessao
          ? PageLoader.home
          : PageLoader.welcome,
      onGenerateRoute: PageLoader.generateRoute,
    );
  }
}
