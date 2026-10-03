import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/pages/missions.dart';
import 'package:conport/pages/rewards.dart';

void main() {
  testWidgets('exibe as missões mockadas', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const Missions()),
    );

    expect(find.text('Plantar 2 mudas'), findsOneWidget);
    expect(find.text('Recicle 3 garrafas'), findsOneWidget);
    expect(find.text('Pote de planta'), findsOneWidget);
    expect(find.text('Em andamento'), findsNWidgets(3));
  });

  testWidgets('navega de missões para recompensas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Missions(),
        onGenerateRoute: PageLoader.generateRoute,
      ),
    );

    await tester.tap(find.text('Recompensas').first);
    await tester.pumpAndSettle();

    expect(find.text('Seu saldo'), findsOneWidget);
    expect(find.text('Muda nativa'), findsOneWidget);
  });

  testWidgets('a tela de recompensas possui retorno para missões', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const Rewards()),
    );

    expect(find.text('Voltar para missões'), findsOneWidget);
    expect(find.text('Caneca reutilizável'), findsOneWidget);
  });
}
