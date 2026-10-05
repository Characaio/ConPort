import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/notificacoes/notificacao_controller.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/conquista_mock.dart';
import 'package:conport/mocks/notificacao_mock.dart';
import 'package:conport/mocks/usuario_mock.dart';

/// Until aqui nada criava notificação: o backend tinha as rotas, mas nenhum
/// código as chamava. A conquista é o único dos quatro avisos que nasce no
/// app (só ele sabe o texto "Alerta!"); cadastro e amizade nascem no backend.
void main() {
  setUp(() {
    Conquistas.instance.reiniciar();
    ConquistaMock.reiniciar();
    NotificacaoMock.reiniciar();
    NotificacaoController.instance.limpar();
    AuthSession.instance.entrar(UsuarioMock.pegarDados(2));
  });

  tearDown(() {
    AuthSession.instance.encerrar();
    NotificacaoController.instance.limpar();
  });

  /// Tela mínima: o registrarConquista precisa de um Scaffold para o aviso.
  Widget tela() => MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(),
      );

  testWidgets('desbloquear uma conquista cria a notificação do sino', (
    tester,
  ) async {
    await tester.pumpWidget(tela());

    await tester.runAsync(() async {
      await registrarConquista(
        tester.element(find.byType(Scaffold)),
        TipoConquista.reportEnviado,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    // A conquista continua valendo e o sino recebeu o aviso.
    expect(Conquistas.instance.estaDesbloqueada(TipoConquista.reportEnviado), isTrue);

    final notificacoes = NotificacaoMock.listar(2);

    expect(notificacoes, isNotEmpty);

    final conquista = notificacoes.firstWhere(
      (n) => n.titulo == 'Conquista desbloqueada!',
    );

    // O texto carrega o título da conquista: é o único jeito de o app ter
    // uma notificação legível, já que o backend guarda só a chave.
    expect(conquista.texto, contains(ConquistaMock.todas.first.titulo));
  });

  testWidgets('conquista já liberada não gera notificação nova', (
    tester,
  ) async {
    await tester.pumpWidget(tela());

    await tester.runAsync(() async {
      final context = tester.element(find.byType(Scaffold));

      await registrarConquista(context, TipoConquista.reportEnviado);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await registrarConquista(context, TipoConquista.reportEnviado);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    final doTipo = NotificacaoMock.listar(2)
        .where((n) => n.titulo == 'Conquista desbloqueada!');

    expect(doTipo, hasLength(1));
  });
}