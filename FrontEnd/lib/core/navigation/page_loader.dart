import 'package:flutter/material.dart';

import 'package:conport/pages/profile.dart';
import 'package:conport/pages/map.dart';
import 'package:conport/pages/home.dart';
import 'package:conport/pages/report.dart';
import 'package:conport/pages/listrepo.dart';
import 'package:conport/pages/reportinfo.dart';
import 'package:conport/pages/ecossistema.dart';
import 'package:conport/pages/unitdetails.dart';
import 'package:conport/pages/unitannouncements.dart';
import 'package:conport/pages/friends.dart';
import 'package:conport/pages/missions.dart';
import 'package:conport/pages/rewards.dart';
import 'package:conport/pages/settings.dart';

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
  static const String report = '/report';
  static const String friends = '/amigos';
  static const String profile = '/profile';
  static const String missions = '/missoes';
  static const String rewards = '/recompensas';
  static const String settingsPage = '/configuracoes';
  static const String educacao = '/educacao';

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

      case report:
        return MaterialPageRoute(builder: (_) => const ReportDetails());

      case unit:
        return MaterialPageRoute(
          builder: (_) =>
              MaisInfo(unidadeId: 1, unidadeService: const UnidadeService()),
        );

      case anuncios:
        return MaterialPageRoute(builder: (_) => const Anuncios());

      case friends:
        return MaterialPageRoute(builder: (_) => const Amigos());

      case profile:
        return MaterialPageRoute(
          builder: (_) =>
              Profile(usuarioId: 2, usuarioService: const UsuarioService()),
        );

      case missions:
        return MaterialPageRoute(builder: (_) => const Missions());

      case rewards:
        return MaterialPageRoute(builder: (_) => const Rewards());

      case settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case educacao:
        return MaterialPageRoute(builder: (_) => const EducacaoPage());

      default:
        return MaterialPageRoute(builder: (_) => const Home());
    }
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
