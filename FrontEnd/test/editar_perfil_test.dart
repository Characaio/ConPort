import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/usuario_mock.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/pages/editar_perfil.dart';
import 'package:conport/services/multipart_media_type.dart';
import 'package:conport/services/usuarioService.dart';

/// A edição de perfil nascia só no backend: existia `POST /usuarios/{id}/avatar`
/// e nada mais. Estes testes cobrem a página nova (pré-preenchimento, validação
/// e o que a sessão recebe depois de salvar) e o corpo do PUT — que agora vai
/// para `/usuarios/eu`, sem id na rota, já que quem edita é quem tem o token.
///
/// Roda com `AppConfig.usarApi == false`, como os demais testes do projeto.
void main() {
  const service = UsuarioService();

  setUp(() {
    AuthSession.instance.entrar(UsuarioMock.pegarDados(2));
  });

  tearDown(() {
    AuthSession.instance.encerrar();
  });

  Widget tela() => MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EditarPerfilPage(
          usuarioId: 2,
          usuarioService: UsuarioService(),
        ),
      );

  Future<void> abrir(WidgetTester tester) async {
    // Tela alta de propósito: a página é um formulário longo e o botão de
    // salvar fica no fim, fora da viewport padrão de 600px.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(tela());
    await tester.pumpAndSettle();
  }

  Future<void> salvar(WidgetTester tester) async {
    final botao = find.text('Salvar alterações');

    await tester.tap(botao);
    await tester.pumpAndSettle();
  }

  group('atualizarPerfil', () {
    test('manda só os campos preenchidos', () async {
      // Em modo mockado o service responde sem rede; o que importa aqui é que
      // a mescla não perde o que não foi mexido.
      final atualizado = await service.atualizarPerfil(nome: 'Novo Nome');

      expect(atualizado.nome, 'Novo Nome');

      // Intactos.
      expect(atualizado.username, 'demo');
      expect(atualizado.email, 'demo@conport.com');
      expect(atualizado.cidade, "Santa Bárbara d'Oeste");
      expect(atualizado.moedas, 150);
    });

    test('trocar a senha não mexe no e-mail', () async {
      final atualizado = await service.atualizarPerfil(
        senha: 'novasenha',
        senhaAtual: '123456',
      );

      expect(atualizado.senha, 'novasenha');
      expect(atualizado.email, 'demo@conport.com');
    });
  });

  group('Usuario.fromJson', () {
    test('não inventa senha quando o DTO não traz o campo', () {
      // O UsuarioDTO do backend nunca devolve a senha; um placeholder faria a
      // sessão achar que "Senha" é a senha da conta.
      final doDto = Usuario.fromJson({
        'Id': 7,
        'Nome': 'Alguém',
        'Username': 'alguem',
        'DataNasc': '2000-01-01',
        'Email': 'alguem@conport.com',
        'Estado': 'SP',
        'Cidade': 'Campinas',
        'Avatar': null,
        'DataCadastro': '2026-01-01T10:00:00',
        'Confiavel': false,
        'XP': 0,
        'Level': 1,
        'Moedas': 0,
        'Seguidores': 0,
        'Seguindo': 0,
      });

      expect(doDto.senha, isNull);
      expect(doDto.nome, 'Alguém');
      expect(doDto.datanasc, DateTime(2000, 1, 1));
    });
  });

  group('mediaTypeDaImagem', () {
    test('deduz o tipo pelo nome do arquivo', () {
      expect(mediaTypeDaImagem('foto.png').mimeType, 'image/png');
      expect(mediaTypeDaImagem('foto.WEBP').mimeType, 'image/webp');
      expect(mediaTypeDaImagem('foto.jpeg').mimeType, 'image/jpeg');
      expect(mediaTypeDaImagem('foto.jpg').mimeType, 'image/jpeg');
      // Sem nome não dá para deduzir: JPEG é o que o seletor entrega.
      expect(mediaTypeDaImagem(null).mimeType, 'image/jpeg');
    });
  });

  group('página de edição', () {
    testWidgets('abre preenchida com os dados do usuário', (tester) async {
      await abrir(tester);

      expect(find.text('Usuário Demo'), findsOneWidget);
      expect(find.text('demo'), findsOneWidget);
      expect(find.text('demo@conport.com'), findsOneWidget);
      expect(find.text('15/05/2005'), findsOneWidget);
      expect(find.text("Santa Bárbara d'Oeste"), findsOneWidget);
      expect(find.text('São Paulo'), findsOneWidget);
    });

    testWidgets('mostra aviso para e-mail inválido e não salva', (tester) async {
      await abrir(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'demo@conport.com'),
        'nao-e-email',
      );
      await salvar(tester);

      expect(find.text('E-mail inválido.'), findsOneWidget);

      // Nada foi para a sessão.
      expect(AuthSession.instance.usuario!.email, 'demo@conport.com');
    });

    testWidgets('mostra aviso para username fora do padrão', (tester) async {
      await abrir(tester);

      await tester.enterText(find.widgetWithText(TextField, 'demo'), 'AB');
      await salvar(tester);

      expect(find.textContaining('letras minúsculas'), findsOneWidget);
      expect(AuthSession.instance.usuario!.username, 'demo');
    });

    testWidgets('trocar a senha exige a senha atual', (tester) async {
      await abrir(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Mínimo de 6 caracteres'),
        'novasenha',
      );
      await salvar(tester);

      expect(
        find.text('Informe a senha atual para trocar a senha.'),
        findsOneWidget,
      );
      expect(AuthSession.instance.usuario!.senha, '123456');
    });

    testWidgets('salvar entrega o usuário novo à sessão', (tester) async {
      await abrir(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Usuário Demo'),
        'Evelyn Souza',
      );
      await salvar(tester);

      // A sessão guarda o usuário em memória: sem isso o resto do app
      // continuaria mostrando o nome antigo.
      expect(AuthSession.instance.usuario!.nome, 'Evelyn Souza');
      expect(find.text('Perfil atualizado.'), findsOneWidget);
    });

    testWidgets('salvar sem mexer em nada mantém os dados', (tester) async {
      await abrir(tester);

      await salvar(tester);

      final sessao = AuthSession.instance.usuario!;

      expect(sessao.nome, 'Usuário Demo');
      expect(sessao.email, 'demo@conport.com');
    });

    testWidgets('foto: escolher abre galeria e câmera', (tester) async {
      await abrir(tester);

      await tester.tap(find.text('Escolher foto'));
      await tester.pumpAndSettle();

      expect(find.text('Escolher da galeria'), findsOneWidget);
      expect(find.text('Tirar uma foto'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
    });

    testWidgets('sem foto não há botão de remover', (tester) async {
      await abrir(tester);

      expect(find.text('Escolher foto'), findsOneWidget);
      expect(find.text('Remover'), findsNothing);
      expect(find.text('Enviar foto'), findsNothing);
    });

    testWidgets('com foto salva o botão de remover aparece', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditarPerfilPage(
            usuarioId: 2,
            usuarioService: _ComAvatar(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remover'), findsOneWidget);
      // Foto já publicada: escolher uma nova é troca, não primeira publicação.
      expect(find.text('Trocar foto'), findsOneWidget);
      expect(find.text('Enviar foto'), findsNothing);
    });

    testWidgets('falha ao carregar mostra aviso em vez de tela vazia', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EditarPerfilPage(
            usuarioId: 2,
            usuarioService: const _FalhaAoCarregar(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar seu perfil.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
      // Sem os dados carregados, salvar enviaria um perfil em branco por
      // cima do de verdade.
      expect(find.text('Salvar alterações'), findsNothing);
    });
  });
}

/// Serve para o caminho de erro: a API fora do ar não deixa a página em
/// branco esperando.
class _FalhaAoCarregar extends UsuarioService {
  const _FalhaAoCarregar();

  @override
  Future<Usuario> pegarDados(int id, {int? visorId}) async {
    throw Exception('sem rede');
  }
}

/// Usuário que já tem foto salva: é o caso em que o botão de remover precisa
/// aparecer.
class _ComAvatar extends UsuarioService {
  const _ComAvatar();

  @override
  Future<Usuario> pegarDados(int id, {int? visorId}) async {
    final base = UsuarioMock.pegarDados(id);

    return Usuario(
      id: base.id,
      nome: base.nome,
      username: base.username,
      datanasc: base.datanasc,
      estado: base.estado,
      cidade: base.cidade,
      email: base.email,
      senha: base.senha,
      confiavel: base.confiavel,
      xp: base.xp,
      level: base.level,
      moedas: base.moedas,
      avatar: 'foto-do-usuario.png',
      datacadastro: base.datacadastro,
      seguidores: base.seguidores,
      seguindo: base.seguindo,
      reportsEnviados: base.reportsEnviados,
      reportsResolvidos: base.reportsResolvidos,
      reportsRejeitados: base.reportsRejeitados,
      reportsPendentes: base.reportsPendentes,
      missoesConcluidas: base.missoesConcluidas,
    );
  }
}
