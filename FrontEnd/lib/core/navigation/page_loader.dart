import 'package:flutter/material.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/pages/profile.dart';
import 'package:conport/pages/map.dart';
import 'package:conport/pages/home.dart';
import 'package:conport/pages/report.dart';
import 'package:conport/pages/listrepo.dart';
import 'package:conport/pages/ecossistema.dart';
import 'package:conport/pages/unitdetails.dart';
import 'package:conport/pages/unitannouncements.dart';
import 'package:conport/pages/friends.dart';
import 'package:conport/pages/missions.dart';
import 'package:conport/pages/rewards.dart';
import 'package:conport/pages/settings.dart';
import 'package:conport/pages/editar_perfil.dart';
import 'package:conport/pages/welcome.dart';
import 'package:conport/pages/login.dart';
import 'package:conport/pages/register.dart';

import 'package:conport/pages/educacao.dart';
import 'package:conport/services/unidadeService.dart';
import 'package:conport/services/usuarioService.dart';

class PageLoader {
  static const String home = '/';
  static const String map = '/mapa';
  static const String unit = '/unidade';
  static const String ecossistema = '/ecossistema';
  static const String anuncios = '/anuncios';
  static const String criarreport = '/criar-report';
  static const String myreports = '/meus-reports';
  static const String friends = '/amigos';
  static const String profile = '/profile';
  static const String missions = '/missoes';
  static const String rewards = '/recompensas';
  static const String settingsPage = '/configuracoes';
  static const String editarPerfil = '/editar-perfil';
  static const String educacao = '/educacao';

  // Acesso
  static const String welcome = '/bem-vindo';
  static const String login = '/entrar';
  static const String register = '/cadastro';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());

      case map:
        return MaterialPageRoute(builder: (_) => const Map());

      case ecossistema:
        return MaterialPageRoute(builder: (_) => const EcossistemaPage());

      case criarreport:
        return MaterialPageRoute(builder: (_) => const Report());

      case myreports:
        return MaterialPageRoute(builder: (_) => const SeusReports());

      case unit:
        return MaterialPageRoute(
          builder: (_) =>
              MaisInfo(unidadeId: 1, unidadeService: const UnidadeService()),
        );

      case anuncios:
        return MaterialPageRoute(builder: (_) => const Anuncios());

      case friends:
        return MaterialPageRoute(builder: (_) => _amigosDaSessao());

      case profile:
        return MaterialPageRoute(builder: (_) => _perfilDaSessao());

      case missions:
        return MaterialPageRoute(builder: (_) => const Missions());

      case rewards:
        return MaterialPageRoute(builder: (_) => const Rewards());

      case settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case editarPerfil:
        return MaterialPageRoute(builder: (_) => _edicaoDaSessao());

      case educacao:
        return MaterialPageRoute(builder: (_) => const EducacaoPage());

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      default:
        return MaterialPageRoute(builder: (_) => const Home());
    }
  }

  /// Perfil e amigos são sempre os da sessão: sem id fixo, quem loga vê o
  /// próprio perfil. Sem login, pede a conta em vez de abrir o de outra pessoa.
  static Widget _perfilDaSessao() {
    final usuario = AuthSession.instance.usuario;

    if (usuario == null) {
      return const _PrecisaLogin();
    }

    return Profile(
      usuarioId: usuario.id,
      usuarioService: const UsuarioService(),
    );
  }

  /// Editar perfil é sempre o da sessão: sem id fixo, a edição cairia na
  /// conta errada.
  static Widget _edicaoDaSessao() {
    final usuario = AuthSession.instance.usuario;

    if (usuario == null) {
      return const _PrecisaLogin();
    }

    return EditarPerfilPage(
      usuarioId: usuario.id,
      usuarioService: const UsuarioService(),
    );
  }

  static Widget _amigosDaSessao() {
    final usuario = AuthSession.instance.usuario;

    if (usuario == null) {
      return const _PrecisaLogin();
    }

    return Amigos(
      usuarioId: usuario.id,
      usuarioService: const UsuarioService(),
    );
  }

  static void go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void replace(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}

/// Página e amigos exigem conta: em vez de abrir o perfil de outra pessoa,
/// manda para o login.
class _PrecisaLogin extends StatelessWidget {
  const _PrecisaLogin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Entre na sua conta para ver isso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => PageLoader.replace(context, PageLoader.login),
                  child: const Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
