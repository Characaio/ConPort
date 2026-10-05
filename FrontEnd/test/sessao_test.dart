import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:conport/core/session/api_client.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/session/token_store.dart';
import 'package:conport/main.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/pages/welcome.dart';

/// A sessão com token tem três partes que podem quebrar isoladamente: o token
/// no cofre do aparelho, a volta da sessão na abertura do app e o header que
/// sai em cada chamada. Estes testes cobrem as três sem subir servidor.
void main() {
  late TokenStoreMemoria cofre;

  /// O token guardado é gravado em segundo plano: o [enter] devolve na hora e
  /// a escrita no cofre acontece logo depois. Um `await` de um evento dá a
  /// vez para ela acontecer.
  Future<void> assentar() => Future<void>.delayed(Duration.zero);

  final carlos = Usuario(
    id: 1,
    nome: 'Carlos Silva',
    datanasc: DateTime(2001, 5, 14),
    estado: 'São Paulo',
    cidade: "Santa Bárbara d'Oeste",
    email: 'carlos.silva@gmail.com',
    confiavel: true,
    xp: 150,
    level: 2,
    moedas: 80,
    username: 'carlos',
  );

  setUp(() async {
    cofre = TokenStoreMemoria();
    TokenStore.instancia = cofre;

    AuthSession.instance.encerrar();

    // O `encerrar` apaga o cofre em segundo plano; sem esperar, a limpeza
    // pendente cairia no meio do próximo teste.
    await assentar();
  });

  tearDown(() {
    ApiClient.cliente = null;
    TokenStore.instancia = TokenStoreSeguro();
    AuthSession.instance.encerrar();
  });

  // ============================================================
  // RESTAURAR NA ABERTURA
  // ============================================================

  group('restaurar', () {
    test('sem token guardado não abre sessão nem fala com o servidor', () async {
      var sondou = false;

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) async {
          sondou = true;
          return carlos;
        },
      );

      expect(voltou, isFalse);
      expect(sondou, isFalse, reason: 'sem token não há o que provar');
      expect(AuthSession.instance.logado, isFalse);
    });

    test('token guardado e aceito reconstrói a sessão', () async {
      cofre.token = 'token-do-carlos';

      String? recebido;

      final voltou = await AuthSession.instance.restaurar(
        sonda: (token) async {
          recebido = token;
          return carlos;
        },
      );

      expect(voltou, isTrue);
      expect(recebido, 'token-do-carlos');
      expect(AuthSession.instance.logado, isTrue);
      expect(AuthSession.instance.token, 'token-do-carlos');
      expect(AuthSession.instance.usuario?.nome, 'Carlos Silva');
      expect(AuthSession.instance.visitante, isFalse);
      // Entrar direto no app não é a mesma coisa que sessão expirada.
      expect(AuthSession.instance.expirada, isFalse);
    });

    test('token recusado é apagado do cofre', () async {
      cofre.token = 'token-velho';

      final limpadasAntes = cofre.limpeza;

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) async => null,
      );

      expect(voltou, isFalse);
      expect(AuthSession.instance.logado, isFalse);
      // Guardar token morto só faz o app tentar de novo a cada abertura.
      expect(cofre.token, isNull);
      expect(cofre.limpeza, limpadasAntes + 1);
    });

    test('rede fora mantém o token para a próxima abertura', () async {
      cofre.token = 'token-do-carlos';

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) async => throw Exception('conexão recusada'),
      );

      expect(voltou, isFalse);
      expect(AuthSession.instance.logado, isFalse);
      // Não foi o servidor que recusou: o token continua válido e vale a pena
      // tentar de novo amanhã sem obrigar a pessoa a entrar.
      expect(cofre.token, 'token-do-carlos');
    });

    test('token em branco não é usado como token', () async {
      cofre.token = '';

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) async => carlos,
      );

      expect(voltou, isFalse);
      expect(AuthSession.instance.logado, isFalse);
    });

    // Sem esses limites um Future pendurado segurava a tela de abertura para
    // sempre: foi exatamente assim que o app ficou preso na tela verde.
    test('cofre que nunca responde não prende a restauração', () async {
      TokenStore.instancia = _CofrePendurado();

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) async => carlos,
        limite: const Duration(milliseconds: 50),
      );

      expect(voltou, isFalse);
      expect(AuthSession.instance.logado, isFalse);
      // Sem leitura não há como saber quem é: o cofre não é apagado.
      expect(cofre.token, isNull);
    });

    test('sonda que nunca responde não prende a restauração', () async {
      cofre.token = 'token-do-carlos';

      final voltou = await AuthSession.instance.restaurar(
        sonda: (_) => Completer<Usuario>().future,
        limite: const Duration(milliseconds: 50),
      );

      expect(voltou, isFalse);
      expect(AuthSession.instance.logado, isFalse);
      // Não foi recusa: sem resposta o token fica para a próxima abertura.
      expect(cofre.token, 'token-do-carlos');
    });
  });

  // ============================================================
  // ENTRAR E SAIR
  // ============================================================

  group('entrar e sair', () {
    test('entrar guarda o token no cofre', () async {
      AuthSession.instance.entrar(carlos, token: 'token-novo');

      expect(AuthSession.instance.logado, isTrue);

      await assentar();

      expect(cofre.token, 'token-novo');
      expect(cofre.gravuras, 1);
    });

    test('entrar sem token não grava nada (modo mock)', () async {
      AuthSession.instance.entrar(carlos);

      await assentar();

      expect(cofre.token, isNull);
      expect(cofre.gravuras, 0);
    });

    test('encerrar limpa a sessão e o cofre', () async {
      AuthSession.instance.entrar(carlos, token: 'token-novo');
      await assentar();

      AuthSession.instance.encerrar();
      await assentar();

      expect(AuthSession.instance.logado, isFalse);
      expect(AuthSession.instance.token, isNull);
      expect(AuthSession.instance.temSessao, isFalse);
      expect(cofre.token, isNull);
    });

    test('entrar como visitante apaga o token da conta anterior', () async {
      AuthSession.instance.entrar(carlos, token: 'token-do-carlos');
      await assentar();

      AuthSession.instance.entrarComoVisitante();
      await assentar();

      expect(AuthSession.instance.visitante, isTrue);
      expect(AuthSession.instance.token, isNull);
      // Sem isso a próxima abertura ressuscitaria a conta que a pessoa deixou.
      expect(cofre.token, isNull);
    });

    test('sair da conta limpa a sessão mesmo sem API', () async {
      AuthSession.instance.entrar(carlos, token: 'token-do-carlos');
      await assentar();

      // `usarApi = false` na suíte: não há servidor, mas a saída tem que
      // acontecer mesmo assim.
      await AuthSession.instance.sairDaConta();
      await assentar();

      expect(AuthSession.instance.logado, isFalse);
      expect(cofre.token, isNull);
    });
  });

  // ============================================================
  // TOKEN RECUSADO
  // ============================================================

  group('token recusado pelo servidor', () {
    test('derruba a sessão, avisa e apaga o token', () async {
      AuthSession.instance.entrar(carlos, token: 'token-morto');
      await assentar();

      AuthSession.instance.tokenRecusado();
      await assentar();

      expect(AuthSession.instance.logado, isFalse);
      expect(AuthSession.instance.token, isNull);
      expect(AuthSession.instance.expirada, isTrue);
      expect(cofre.token, isNull);
    });

    test('na abertura do app não conta como sessão expirada', () async {
      // Sem ninguém logado, um 401 é só um token guardado que não vale mais —
      // não faz sentido anunciar "sua sessão expirou" para quem nem entrou.
      AuthSession.instance.tokenRecusado();

      expect(AuthSession.instance.expirada, isFalse);
      expect(AuthSession.instance.logado, isFalse);
    });
  });

  // ============================================================
  // HEADER DE AUTORIZAÇÃO
  // ============================================================

  group('ApiClient', () {
    Uri alvo() => Uri.parse('http://localhost:8080/usuarios/eu');

    test('sem sessão não manda Authorization', () {
      expect(ApiClient.cabecalhos(), isEmpty);
    });

    test('com sessão manda Bearer', () {
      AuthSession.instance.entrar(carlos, token: 'abc123');

      expect(
        ApiClient.cabecalhos()['Authorization'],
        'Bearer abc123',
      );
    });

    test('json acrescenta o Content-Type', () {
      final headers = ApiClient.cabecalhos(json: true);

      expect(headers['Content-Type'], 'application/json');
    });

    test('o token da chamada tem prioridade sobre o da sessão', () async {
      AuthSession.instance.entrar(carlos, token: 'token-da-sessao');

      String? authorization;

      ApiClient.cliente = MockClient((request) async {
        authorization = request.headers['Authorization'];

        return http.Response('{}', 200);
      });

      await ApiClient.get(alvo(), token: 'token-da-sondagem');

      expect(authorization, 'Bearer token-da-sondagem');
    });

    test('401 em chamada autenticada derruba a sessão', () async {
      AuthSession.instance.entrar(carlos, token: 'token-morto');
      await assentar();

      ApiClient.cliente = MockClient(
        (request) async => http.Response('{"mensagem":"Sessão expirada."}', 401),
      );

      await ApiClient.get(alvo());

      expect(AuthSession.instance.logado, isFalse);
      expect(AuthSession.instance.expirada, isTrue);
      expect(cofre.token, isNull);
    });

    test('401 sem token (login errado) não derruba a sessão', () async {
      ApiClient.cliente = MockClient(
        (request) async => http.Response('{"mensagem":"E-mail ou senha incorretos."}', 401),
      );

      final response = await ApiClient.postJson(
        alvo(),
        {'email': 'ninguem@conport.com', 'senha': 'xxxxxx'},
      );

      expect(response.statusCode, 401);
      expect(AuthSession.instance.expirada, isFalse);
      expect(AuthSession.instance.logado, isFalse);
    });

    test('erro que não é 401 devolve a resposta sem mexer na sessão', () async {
      AuthSession.instance.entrar(carlos, token: 'token-ok');

      ApiClient.cliente = MockClient(
        (request) async => http.Response('{"mensagem":"Dados inválidos"}', 400),
      );

      final response = await ApiClient.get(alvo());

      expect(response.statusCode, 400);
      expect(AuthSession.instance.logado, isTrue);
      expect(AuthSession.instance.token, 'token-ok');
    });
  });

  // ============================================================
  // COFRE FORA DO AR
  // ============================================================

  group('cofre indisponível', () {
    /// Simula o desktop sem backend de cofre (ou o plugin ausente): tudo
    /// estoura. Nenhum desses erros pode derrubar o app — no máximo a pessoa
    /// entra de novo.
    test('não derruba nem a leitura nem a escrita', () async {
      final quebrado = TokenStoreSeguro(storage: _CofreQuebrado());

      expect(await quebrado.ler(), isNull);
      await quebrado.gravar('token');
      await quebrado.apagar();
    });

    /// O caso que prendeu a tela verde: o plugin não registrado no web não
    /// lança erro nenhum, o Future simplesmente nunca completa.
    test('cofre sem resposta estoura o limite da leitura', () async {
      final pendurado = TokenStoreSeguro(
        storage: _PluginPendurado(),
        limite: const Duration(milliseconds: 50),
      );

      expect(await pendurado.ler(), isNull);
    });
  });

// ============================================================
  // ABERTURA DO APP
  // ============================================================

  group('abertura do app', () {
    testWidgets('sem sessão começa na tela de acesso', (tester) async {
      await tester.pumpWidget(const Conport());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);

      // Deixa os temporizadores do app vencerem antes de desmontar a árvore.
      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();
    });

    testWidgets('token recusado no meio do uso traz o app de volta', (
      tester,
    ) async {
      await tester.pumpWidget(const Conport());
      await tester.pumpAndSettle();

      // A pessoa entra durante o uso (é o mesmo caminho do login na tela).
      AuthSession.instance.entrar(carlos, token: 'token-que-expira');
      await tester.pump();

      // O servidor recusa numa chamada: a sessão cai sozinha.
      AuthSession.instance.tokenRecusado();
      await tester.pumpAndSettle();

      expect(AuthSession.instance.logado, isFalse);
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('Sua sessão expirou. Entre de novo.'), findsOneWidget);

      // Deixa o SnackBar e os temporizadores do app terminarem para não sobrar
      // timer pendente no fim do teste.
      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();
    });

    /// A regressão da tela verde: o cofre não responde nunca, e mesmo assim o
    /// app tem que sair da tela de carregamento.
    testWidgets('cofre que nunca responde não prende a tela de abertura', (
      tester,
    ) async {
      TokenStore.instancia = _CofrePendurado();

      await tester.pumpWidget(const Abertura());

      // Vence o limite da restauração; sem ele o spinner giraria para sempre.
      await tester.pump(const Duration(seconds: 11));

      expect(find.byType(Conport), findsOneWidget);
      expect(find.byType(WelcomePage), findsOneWidget);

      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();
    });
  });
}

/// Cofre que nunca responde: o Future fica pendurado para sempre, como o
/// plugin do cofre fora do registrant (o caso que prendeu a abertura).
class _CofrePendurado implements TokenStore {
  @override
  Future<String?> ler() => Completer<String?>().future;

  @override
  Future<void> gravar(String token) => Completer<void>().future;

  @override
  Future<void> apagar() => Completer<void>().future;
}

/// A mesma pendurada, mas na camada do plugin — onde ela acontece de verdade.
class _PluginPendurado extends FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => Completer<String?>().future;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => Completer<void>().future;

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => Completer<void>().future;
}

/// Cofre que sempre falha, para o caminho de erro do [TokenStoreSeguro].
class _CofreQuebrado extends FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => throw Exception('sem cofre');

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => throw Exception('sem cofre');

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => throw Exception('sem cofre');
}