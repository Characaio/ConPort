import 'package:flutter/material.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/core/navigation/page_loader.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: PageLoader.home,
      onGenerateRoute: PageLoader.generateRoute,
    );
  }
}
