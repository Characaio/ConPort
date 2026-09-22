import 'package:conport/pages/dtrepo.dart';
import 'package:flutter/material.dart';
import 'package:conport/pages/home.dart';
import 'package:conport/pages/Myrepo.dart';
import 'package:conport/pages/dtrepo.dart';

void main() {
  runApp(const Conport());
}

class Conport extends StatelessWidget {
  const Conport({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conport',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PageLoader(),
    );
  }
}

class PageLoader extends StatelessWidget {
  const PageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Dtrepo();
  }
}
