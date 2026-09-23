import 'package:conport/services/usuarioService.dart';
import 'package:conport/services/unidadeService.dart';
import 'package:flutter/material.dart';

import 'package:conport/pages/home.dart';
import 'package:conport/pages/dtrepo.dart';
import 'package:conport/pages/myrepo.dart';
import 'package:conport/pages/reports.dart';
import 'package:conport/pages/dtunit.dart';
import 'package:conport/pages/profile.dart';

class PageLoader {
  static const String home = '/';
  static const String reports = '/reports';
  static const String myreports = '/myreports';
  static const String report = '/report';
  static const String unit = '/unit';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home(unidadeId: 1, unidadeService: UnidadeService()));

      case reports:
        return MaterialPageRoute(builder: (_) => const Reports());

      case myreports:
        return MaterialPageRoute(builder: (_) => const Myrepo());

      case report:
        return MaterialPageRoute(builder: (_) => const Dtrepo());

      case unit:
        return MaterialPageRoute(
          builder: (_) => UnidadeDetalhes(unidadeId:1, unidadeService: UnidadeService()),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const Profile(usuarioId: 2, usuarioService: UsuarioService()));

      default:
        return MaterialPageRoute(builder: (_) => const Home(unidadeId: 1, unidadeService: UnidadeService()));
    }
  }

  static void go(BuildContext context, String page) {
    Navigator.of(context).pushNamed(page);
  }

  static void replace(BuildContext context, String page) {
    Navigator.of(context).pushReplacementNamed(page);
  }

  static void back(BuildContext context) {
    Navigator.of(context).pop();
  }
}
