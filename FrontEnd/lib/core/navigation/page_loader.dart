import 'package:flutter/material.dart';

import 'package:conport/pages/profile.dart';
import 'package:conport/pages/dtunit.dart';

import 'package:conport/pages/map.dart';
import 'package:conport/pages/home.dart';
import 'package:conport/pages/report.dart';
import 'package:conport/pages/listrepo.dart';
import 'package:conport/pages/reportinfo.dart';

import 'package:conport/services/unidadeService.dart';
import 'package:conport/services/usuarioService.dart';

class PageLoader {
  static const String home = '/';
  static const String map = '/map';
  static const String criarreport = '/criar-report';
  static const String myreports = '/meus-reports';
  static const String report = '/report';
  static const String unit = '/unit';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => SafeArea(child: Home()));

      case map:
        return MaterialPageRoute(builder: (_) => const SafeArea(child: Map()));

      case criarreport:
        return MaterialPageRoute(
          builder: (_) => const SafeArea(child: Report()),
        );

      case myreports:
        return MaterialPageRoute(
          builder: (_) => const SafeArea(child: SeusReports()),
        );

      case report:
        return MaterialPageRoute(
          builder: (_) => const SafeArea(child: ReportDetails()),
        );

      case unit:
        return MaterialPageRoute(
          builder: (_) => SafeArea(
            child: UnidadeDetalhes(
              unidadeId: 1,
              unidadeService: const UnidadeService(),
            ),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => SafeArea(
            child: Profile(
              usuarioId: 2,
              usuarioService: const UsuarioService(),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              // Home(unidadeId: 1, unidadeService: const UnidadeService()),
              SafeArea(child: Home()),
        );
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
