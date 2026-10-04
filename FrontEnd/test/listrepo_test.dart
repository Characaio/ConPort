import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/usuario_mock.dart';
import 'package:conport/models/report.dart';
import 'package:conport/models/report_lista.dart';
import 'package:conport/pages/listrepo.dart';
import 'package:conport/pages/reportinfo.dart';

/// Monta um ReportLista sem passar pela API.
ReportLista _report({
  required int id,
  required StatusReport status,
  required TipoDeIncidente tipo,
  String? supervisor,
  String? motivo,
}) {
  return ReportLista(
    id: id,
    unidadeId: 1,
    unidadeNome: 'Parque Estadual de Exemplo',
    usuarioId: 2,
    usuarioNome: 'Usuário Demo',
    tipo: tipo,
    status: status,
    dataDoOcorrido: DateTime(2026, 3, 20, 14, 30),
    descricao: 'Descrição do report $id',
    quantidadeAnexos: 0,
    supervisorNome: supervisor,
    motivoDaNegacao: motivo,
  );
}

Widget _tela() => MaterialApp(
      theme: AppTheme.lightTheme,
      home: const SeusReports(),
    );

void main() {
  setUp(() {
    AuthSession.instance.entrar(UsuarioMock.pegarDados(2));
  });

  tearDown(() {
    AuthSession.instance.encerrar();
  });

  testWidgets('pede login quando não há sessão', (tester) async {
    AuthSession.instance.encerrar();

    await tester.pumpWidget(_tela());
    await tester.pumpAndSettle();

    expect(find.textContaining('Entre na sua conta'), findsOneWidget);
  });

  testWidgets('agrupa os reports por status nas abas', (tester) async {
    await tester.pumpWidget(_tela());
    await tester.pumpAndSettle();

    // Só existem abas com reports.
    expect(find.text('Pendentes (1)'), findsOneWidget);
    expect(find.text('Negados (1)'), findsOneWidget);
    expect(find.text('Tratados (1)'), findsOneWidget);

    // Aba sem nada não aparece.
    expect(find.text('Em andamento (0)'), findsNothing);

    // Abre na primeira aba com conteudo: o unico pendente do mock.
    expect(find.text('Animal ferido'), findsOneWidget);
  });

  testWidgets('troca de aba mostra os reports daquele status', (tester) async {
    await tester.pumpWidget(_tela());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Negados (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Poluição'), findsOneWidget);
    expect(find.textContaining('Fora da área monitorada'), findsOneWidget);

    // O da outra aba sumiu.
    expect(find.text('Animal ferido'), findsNothing);
  });

  testWidgets('abre o detalhe do report ao tocar no card', (tester) async {
    await tester.pumpWidget(_tela());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Animal ferido'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportDetails), findsOneWidget);

    // Report pendente: mostra quem ainda vai analisar e a descrição real.
    expect(find.textContaining('Aguardando análise'), findsOneWidget);
    expect(
      find.text('Animal ferido próximo à trilha principal.'),
      findsOneWidget,
    );
  });

  testWidgets('a barra de urgência do detalhe cresce até o valor', (
    tester,
  ) async {
    // Regressão: a barra aparecia estática, já cheia no primeiro frame.
    final report = ReportLista.fromJson({
      'Id': 9,
      'UnidadeId': 1,
      'UnidadeNome': 'Parque Estadual',
      'UsuarioId': 2,
      'UsuarioNome': 'Ana Oliveira',
      'Tipo': 'QUEIMADA',
      'Status': 'PENDENTE',
      'Prioridade': 'ALTA',
      'DataDoOcorrido': '2026-03-25T16:15:20',
      'Descricao': 'Fogo na encosta',
      'QuantidadeAnexos': 0,
    });

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: ReportDetails(report: report)),
    );

    // Primeiro frame: ainda não cresceu.
    double fator() => tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .map((w) => w.widthFactor)
        .firstWhere((f) => f != null)!;

    expect(fator(), 0);

    await tester.pump(const Duration(milliseconds: 200));
    expect(fator(), greaterThan(0));
    expect(fator(), lessThan(0.75));

    await tester.pumpAndSettle();

    // ALTA = 3 de 4 = 0.75 da barra.
    expect(fator(), 0.75);
  });

  test('ReportLista.fromJson lê o que o backend devolve', () {
    final report = ReportLista.fromJson({
      'Id': 7,
      'UnidadeId': 1,
      'UnidadeNome': 'Parque Estadual',
      'UsuarioId': 2,
      'UsuarioNome': 'Ana Oliveira',
      'Tipo': 'ANIMAL_EXOTICO',
      'Status': 'PENDENTE',
      'Prioridade': 'MEDIA',
      'DataDoOcorrido': '2026-03-25T16:15:20',
      'Descricao': 'Javali avistado',
      'Latitude': -22.9,
      'Longitude': -47.1,
      'QuantidadeAnexos': 3,
      'SupervisorNome': null,
      'DataDaAnalise': null,
      'MotivoDaNegacao': null,
    });

    expect(report.id, 7);
    expect(report.tipo, TipoDeIncidente.ANIMAL_EXOTICO);
    expect(report.status, StatusReport.PENDNTE);
    expect(report.quantidadeAnexos, 3);
    expect(report.prioridade, 'MEDIA');
    expect(report.supervisorNome, isNull);
    expect(report.localizacao, 'Parque Estadual');
  });

  test('ReportLista.fromJson aceita o status com acento', () {
    final report = ReportLista.fromJson({
      'Id': 8,
      'UnidadeId': 1,
      'UnidadeNome': '',
      'UsuarioId': 2,
      'UsuarioNome': '',
      'Tipo': 'POLUIÇÃO',
      'Status': 'SOB_AVALIAÇÃO',
      'DataDoOcorrido': '2026-03-25T16:15:20',
      'Descricao': '',
      'QuantidadeAnexos': 0,
    });

    expect(report.tipo, TipoDeIncidente.POLUICAO);
    expect(report.status, StatusReport.SOB_AVALIACAO);
    expect(report.localizacao, 'Local não informado');
  });
}