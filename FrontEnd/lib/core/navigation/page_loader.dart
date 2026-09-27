import 'package:conport/pages/map.dart';
import 'package:conport/pages/revamphome.dart';
import 'package:flutter/material.dart';

import 'package:conport/pages/home.dart';
import 'package:conport/pages/profile.dart';
import 'package:conport/pages/reports.dart';
import 'package:conport/pages/myrepo.dart';
import 'package:conport/pages/dtrepo.dart';
import 'package:conport/pages/dtunit.dart';

import 'package:conport/services/unidadeService.dart';
import 'package:conport/services/usuarioService.dart';

class PageLoader {
  static const String home = '/';
  static const String map = '/map';
  static const String reports = '/reports';
  static const String myreports = '/myreports';
  static const String report = '/report';
  static const String unit = '/unit';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) =>
              // Home(unidadeId: 1, unidadeService: const UnidadeService()),
              HomeRevamp(),
        );

      case map:
        return MaterialPageRoute(builder: (_) => const Map());

      case reports:
        return MaterialPageRoute(builder: (_) => const Reports());

      case myreports:
        return MaterialPageRoute(builder: (_) => const Myrepo());

      case report:
        return MaterialPageRoute(builder: (_) => const Dtrepo());

      case unit:
        return MaterialPageRoute(
          builder: (_) => UnidadeDetalhes(
            unidadeId: 1,
            unidadeService: const UnidadeService(),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) =>
              Profile(usuarioId: 2, usuarioService: const UsuarioService()),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              // Home(unidadeId: 1, unidadeService: const UnidadeService()),
              HomeRevamp(),
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
