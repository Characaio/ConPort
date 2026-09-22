import 'package:flutter/material.dart';

import 'package:conport/pages/home.dart';
import 'package:conport/pages/dtrepo.dart';
import 'package:conport/pages/myrepo.dart';
import 'package:conport/pages/reports.dart';
import 'package:conport/pages/dtunit.dart';

class PageLoader {
  static const String home = '/';
  static const String reports = '/reports';
  static const String myreports = '/myreports';
  static const String report = '/report';
  static const String unit = '/unit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());

      case reports:
        return MaterialPageRoute(builder: (_) => const Reports());

      case myreports:
        return MaterialPageRoute(builder: (_) => const Myrepo());

      case report:
        return MaterialPageRoute(builder: (_) => const Dtrepo());

      case unit:
        return MaterialPageRoute(
          builder: (_) => UnidadeDetalhes(unidade: unidadeMock),
        );

      default:
        return MaterialPageRoute(builder: (_) => const Home());
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
