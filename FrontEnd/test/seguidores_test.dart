import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/amigo_mock.dart';
import 'package:conport/mocks/conquista_mock.dart';
import 'package:conport/mocks/usuario_mock.dart';

import 'package:conport/models/usuario.dart';
import 'package:conport/pages/profile.dart';
import 'package:conport/services/usuarioService.dart';

/// O sistema de seguidores nasceu sem nada no app: "seguir" era mandar
/// pedido de amizade, não existia lista de seguidores, e o perfil de outra
/// pessoa mostrava as conquistas de quem estava logado.
void main() {
  const service = UsuarioService();

  setUp(() {
    AmigoMock.reiniciar();
    UsuarioMock.reiniciar();
    ConquistaMock.reiniciar();
    Conquistas.instance.reiniciar();
    AuthSession.instance.entrar(UsuarioMock.pegarDados(AmigoMock.eu));
  });

  tearDown(() {
    AuthSession.instance.encerrar();
  });

  Widget tela(int usuarioId) => MaterialApp(
    theme: AppTheme.lightTheme,
    home: Profile(usuarioId: usuarioId, usuarioService: const UsuarioService()),
  );

  Future<void> abrir(WidgetTester tester, int usuarioId) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(tela(usuarioId));
    await tester.pumpAndSettle();
  }

  group('busca', () {
    test('acha por nome e por username', () async {
      // "carlos" bate em Carlos Silva e em Carlos Eduardo: a busca é por
      // nome parecido, não por nome exato.
      final porNome = await service.buscar('carlos');
      final porUsername = await service.buscar('julia');

      expect(
        [for (final u in porNome) u.nome],
        containsAll(['Carlos Silva', 'Carlos Eduardo']),
      );
      expect([for (final u in porUsername) u.nome], ['Júlia Alves']);
    });

    test('não devolve a si mesmo nem quem já é amigo', () async {
      AmigoMock.serAmigos(2, 101);

      final achados = await service.buscar('a');
      final ids = [for (final u in achados) u.id];

      expect(ids, isNot(contains(2)));
      expect(ids, isNot(contains(101)));
    });

    test('termo curto demais não chama o servidor', () async {
      expect(await service.buscar('a'), isEmpty);
    });
  });

  group('seguir', () {
    test('segue e deixa de seguir', () async {
      // O id de quem segue não vai na chamada: é o da sessão (o "eu" do
      // mock), porque com a API quem segue é o dono do token.
      await service.seguir(101);
      expect(AmigoMock.sigo(AmigoMock.eu, 101), isTrue);
      // 101 segue de volta.
      expect(AmigoMock.meSegue(101, AmigoMock.eu), isTrue);

      await service.deixarDeSeguir(101);
      expect(AmigoMock.sigo(AmigoMock.eu, 101), isFalse);
    });

    test('amigo é seguidor mútuo, como no backend', () {
      AmigoMock.serAmigos(2, 103);

      expect(AmigoMock.sigo(2, 103), isTrue);
      expect(AmigoMock.sigo(103, 2), isTrue);
    });

    test('desfazer a amizade não desfaz o follow', () async {
      await service.seguir(103);
      AmigoMock.serAmigos(2, 103);
      AmigoMock.removerAmigo(2, 103);

      expect(AmigoMock.saoAmigos(2, 103), isFalse);
      expect(AmigoMock.sigo(2, 103), isTrue);
    });
  });

  group('privacidade das listas', () {
    test('público deixa qualquer um abrir', () async {
      await service.listarSeguidores(1, visorId: 3);
      await service.listarSeguindo(1, visorId: 3);
    });

    test('privado barra até quem não é você', () async {
      UsuarioMock.definirVisibilidade(1, VisibilidadeSeguidores.privado);

      expect(
        () => service.listarSeguidores(1, visorId: 3),
        throwsA(isA<ListaPrivada>()),
      );

      // O dono sempre vê.
      await service.listarSeguidores(1, visorId: 1);
    });

    test('só amigos barra quem não é amigo', () async {
      UsuarioMock.definirVisibilidade(1, VisibilidadeSeguidores.soAmigos);

      expect(
        () => service.listarSeguindo(1, visorId: 3),
        throwsA(isA<ListaPrivada>()),
      );

      AmigoMock.serAmigos(3, 1);
      await service.listarSeguindo(1, visorId: 3);
    });
  });

  group('perfil de outra pessoa', () {
    testWidgets('oferece seguir e adicionar amigo, sem "Seus Reports"', (
      tester,
    ) async {
      await abrir(tester, 101);

      expect(find.text('Seguir'), findsOneWidget);
      expect(find.text('Adicionar amigo'), findsOneWidget);
      // "Seus Reports" é do seu perfil: no de outra pessoa ia abrir a sua
      // lista, não a dela.
      expect(find.text('Seus Reports'), findsNothing);
    });

    testWidgets('visitante sem sessão não vê os botões', (tester) async {
      AuthSession.instance.encerrar();
      await abrir(tester, 101);

      // Sem conta não há para quem mandar o follow: mostrar um botão que não
      // faz nada é pior do que não mostrar.
      expect(find.text('Seguir'), findsNothing);
      expect(find.text('Adicionar amigo'), findsNothing);
      // A lista de seguidores ainda abre: a de dependência é pública.
      await tester.tap(find.text('Seguidores'));
      await tester.pumpAndSettle();
      expect(find.text('Esta lista é privada.'), findsNothing);
    });

    testWidgets('não oferece esses botões no seu próprio perfil', (
      tester,
    ) async {
      await abrir(tester, AmigoMock.eu);

      expect(find.text('Seguir'), findsNothing);
      expect(find.text('Adicionar amigo'), findsNothing);
      expect(find.text('Seus Reports'), findsOneWidget);
    });

    testWidgets('seguir muda o botão e o contador', (tester) async {
      await abrir(tester, 101);

      // Os dois contadores começam em 0.
      expect(find.text('0'), findsNWidgets(2));

      await tester.tap(find.text('Seguir'));
      await tester.pumpAndSettle();

      // O rótulo do botão virou e o contador de "Seguindo" foi para 1.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Seguindo'), findsNWidgets(2));
    });

    testWidgets('já seguindo mostra o estado, e dá para desfazer', (
      tester,
    ) async {
      await service.seguir(101);
      await abrir(tester, 101);

      // Rótulo do contador + rótulo do botão.
      expect(find.text('Seguindo'), findsNWidgets(2));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Seguindo'));
      await tester.pumpAndSettle();

      expect(find.text('Seguir'), findsOneWidget);
      expect(AmigoMock.sigo(2, 101), isFalse);
    });

    testWidgets('addicionar amigo pede aprovação, não segue', (tester) async {
      await abrir(tester, 101);

      await tester.tap(find.text('Adicionar amigo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Solicitação enviada'), findsOneWidget);
      // Mandar pedido de amizade não cria follow.
      expect(AmigoMock.sigo(2, 101), isFalse);
      expect(AmigoMock.saoAmigos(2, 101), isFalse);
    });

    testWidgets('mostra as conquistas de quem está sendo observado', (
      tester,
    ) async {
      // Três conquistas minhas (usuário da sessão) contra duas da Ana, para
      // os números não se confundirem.
      await Conquistas.instance.desbloquear(TipoConquista.reportEnviado);
      await Conquistas.instance.desbloquear(TipoConquista.videoAssistido);
      await Conquistas.instance.desbloquear(
        TipoConquista.recompensaResgatada,
      );

      expect(Conquistas.instance.desbloqueadas, hasLength(3));
      expect(ConquistaMock.desbloqueadas(101), hasLength(2));

      await abrir(tester, 101);

      // Duas — as do usuário 101. Com o bug antigo saíam três, as minhas.
      expect(find.text('2 de 5 desbloqueadas'), findsOneWidget);
    });

    testWidgets('o próprio perfil continua mostrando as minhas conquistas', (
      tester,
    ) async {
      await Conquistas.instance.desbloquear(TipoConquista.reportEnviado);
      await abrir(tester, AmigoMock.eu);

      expect(find.text('1 de 5 desbloqueadas'), findsOneWidget);
    });

    testWidgets('tocou em Seguidores e a lista abriu', (tester) async {
      // Quem segue a Ana é gente de fora da sessão: isso se monta direto no
      // mock, porque pelo serviço só dá para seguir sendo eu.
      AmigoMock.seguir(3, 101);
      AmigoMock.seguir(102, 101);
      await abrir(tester, 101);

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Seguidores'));
      await tester.pumpAndSettle();

      // Os dois seguidores aparecem com username e nível.
      expect(find.text('Lucas Santos'), findsOneWidget);
      expect(find.text('Carlos Eduardo'), findsOneWidget);
      expect(find.text('@lucas • Nível 1'), findsOneWidget);
      expect(find.text('@carlos.edu • Nível 9'), findsOneWidget);
    });

    testWidgets('lista barrada mostra o motivo em vez de "ninguém"', (
      tester,
    ) async {
      UsuarioMock.definirVisibilidade(101, VisibilidadeSeguidores.privado);
      await abrir(tester, 101);

      await tester.tap(find.text('Seguidores'));
      await tester.pumpAndSettle();

      expect(find.text('Esta lista é privada.'), findsOneWidget);
      expect(find.text('Ninguém por aqui ainda.'), findsNothing);
    });

    testWidgets('a lista abre o perfil de quem foi escolhido', (tester) async {
      await service.seguir(101);
      await abrir(tester, 2);

      await tester.tap(find.text('Seguindo'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Beatriz'), findsWidgets);

      await tester.tap(find.text('Ana Beatriz').last);
      await tester.pumpAndSettle();

      // Abriu o perfil dela, com os botões de ação.
      expect(find.text('Adicionar amigo'), findsOneWidget);
    });
  });
}
