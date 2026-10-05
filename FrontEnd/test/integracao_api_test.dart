import 'package:flutter_test/flutter_test.dart';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/auth_service.dart';
import 'package:conport/services/conquista_service.dart';
import 'package:conport/services/usuarioService.dart';

/// Exercita a sessão por token contra a API de verdade, no container.
///
/// Fica pulado na suíte normal, que roda com `usarApi = false`. Para rodar:
/// deixar `usarApi = true`, subir o `conport-api` e executar só este arquivo.
/// Ele mexe no banco de verdade — por isso não entra no `flutter test` sem
/// filtro.
///
/// O login é feito pelo [AuthService] de propósito: os testes precisam do
/// token que o app receberia, não de um token forjado, e é o caminho que
/// mais dá para quebrar sem o teste acusar.
void main() {
  // O `flutter test` instala, na criação do binding, um `HttpClient` dublê
  // que responde 400 a qualquer endereço — para os testes de widget não
  // dependerem da rede. Aqui a rede é justamente o que se quer testar, então
  // o binding é criado com essa troca desligada (é o mesmo caminho que o
  // `integration_test` usa).
  BindingRedeReal.ensureInitialized();

  const service = UsuarioService();
  const carlos = 1;
  const ana = 2;
  const lucas = 3;

  /// Entra como qualquer pessoa do banco de desenvolvimento.
///
/// Seguidores e quem a pessoa segue só podem ser criados por quem realmente
/// segue ou é seguido: com a sessão por token não existe mais caminho para
/// "seguir em nome de".
Future<void> entrarComEmail(String email) async {
    final resultado = await AuthService().entrar(
      email: email,
      senha: '123456',
    );

    AuthSession.instance.entrar(resultado.usuario, token: resultado.token);
  }

  Future<void> entrarComoCarlos() async {
    await entrarComEmail('carlos.silva@gmail.com');
  }/// Deixa a rede sem follows, amizades nem visibilidade fechada entre os três.
///
/// Roda no [setUp] e no [tearDown] de propósito: se um expect estourar no
  /// meio, a limpeza do fim não acontece e o próximo teste começa sujo.
  Future<void> limpar() async {
    // Precisa de sessão para limpar: quem segue/desfaz é o da conta.
    if (!AuthSession.instance.logado) await entrarComoCarlos();

    for (final alvo in [ana, lucas]) {
      await service.deixarDeSeguir(alvo);
      await service.removerAmigo(alvo);
    }

    // A visibilidade e as relações da Ana também são mexidas pelos testes de
    // privacidade, e cada conta só muda a própria: entrar como ela para
    // desfazer.
    await entrarComEmail('ana.oliveira@gmail.com');

    await service.atualizarVisibilidade(VisibilidadeSeguidores.publico);
    await service.deixarDeSeguir(carlos);
    await service.deixarDeSeguir(lucas);
    await service.removerAmigo(carlos);
    await service.removerAmigo(lucas);

    await entrarComoCarlos();
  }

  /// Garante que as duas contas tenham conquistas diferentes no banco.
  ///
  /// Desbloquear é irreversível pelo backend (não existe rota para apagar
  /// conquista), então isso deixa uma linha em `conquista_desbloqueada` para
  /// cada conta — que é justamente o que o perfil de alguém precisa mostrar.
  Future<void> garantirConquistasDiferentes() async {
    await Conquistas.instance.desbloquear(TipoConquista.videoAssistido);

    await entrarComEmail('ana.oliveira@gmail.com');
    await Conquistas.instance.desbloquear(TipoConquista.avistamentoEnviado);
    await entrarComoCarlos();

    Conquistas.instance.reiniciar();
  }

  setUp(() async {
    await entrarComoCarlos();

    await limpar();
  });

  tearDown(() async {
    await limpar();
    AuthSession.instance.encerrar();
  });

  group(
    'API de verdade',
    () {
      test('login devolve o token e o dono dele', () async {
        final resultado = await AuthService().entrar(
          email: 'carlos.silva@gmail.com',
          senha: '123456',
        );

        expect(resultado.token, isNotNull);
        expect(resultado.token, isNotEmpty);
        expect(resultado.usuario.id, carlos);

        // O token prova a identidade: o perfil de quem tem o token é o dele.
        final eu = await service.minhaConta();

        expect(eu.id, carlos);
      });

      test('perfil traz o estado do relacionamento para quem está vendo', () async {
        final antes = await service.pegarDados(ana);

        expect(antes.amigo, isFalse);
        expect(antes.euSigo, isFalse);
        expect(antes.seguidores, 0);

        await service.seguir(ana);

        final depois = await service.pegarDados(ana);

        expect(depois.euSigo, isTrue);
        expect(depois.seguidores, 1);
        expect(depois.amigo, isFalse, reason: 'seguir não é ser amigo');

        final meu = await service.pegarDados(carlos);

        expect(meu.euSigo, isFalse, reason: 'ninguém segue a si mesmo');
        expect(meu.seguindo, 1);
      });

      test('listas respeitam a visibilidade', () async {
        // Carlos segue Ana.
        await service.seguir(ana);

        expect(
          [for (final a in await service.listarSeguindo(carlos)) a.nome],
          ['Ana Oliveira'],
        );

        // Lucas segue Carlos: precisa ser o Lucas a fazer isso, porque o
        // token é dele.
        await entrarComEmail('lucas.santos@gmail.com');
        await service.seguir(carlos);
        await entrarComoCarlos();

        expect(
          [for (final a in await service.listarSeguidores(carlos)) a.nome],
          ['Lucas Santos'],
        );

        // Quem lê a lista é quem está logado — então a-barreira precisa ser
        // testada de outra conta, não da própria dona.
        await entrarComEmail('ana.oliveira@gmail.com');
        await service.atualizarVisibilidade(VisibilidadeSeguidores.privado);

        // Privado barra o outro; a dona vê.
        await entrarComEmail('lucas.santos@gmail.com');

        expect(
          () => service.listarSeguindo(ana),
          throwsA(isA<ListaPrivada>()),
        );

        await entrarComEmail('ana.oliveira@gmail.com');

        await service.listarSeguindo(ana);

        // Só amigos barra quem não é amigo...
        await service.atualizarVisibilidade(
          VisibilidadeSeguidores.soAmigos,
        );

        await entrarComEmail('lucas.santos@gmail.com');

        expect(
          () => service.listarSeguindo(ana),
          throwsA(isA<ListaPrivada>()),
        );

        // ...até a amizade entre eles ser aceita. Quem pede é o Lucas, quem
        // responde é a Ana — as duas trocas de sessão são parte do que se
        // está testando.
        await service.enviarSolicitacao(ana);

        await entrarComEmail('ana.oliveira@gmail.com');

        final pedidos = await service.listarSolicitacoes();
        expect(pedidos, isNotEmpty);

        // Aceita o pedido do Lucas — e não qualquer um que estiver na fila.
        final doLucas = pedidos.firstWhere((p) => p.id == lucas);

        await service.aceitar(doLucas.relacaoId!);

        await entrarComEmail('lucas.santos@gmail.com');

        await service.listarSeguindo(ana);
      });

      test('busca acha gente por nome parecido e não traz a si mesmo', () async {
        final achados = await service.buscar('lucas');

        expect([for (final a in achados) a.nome], contains('Lucas Santos'));
        expect([for (final a in achados) a.id], isNot(contains(carlos)));
      });

      test('conquistas são por usuário, não da sessão', () async {
        await garantirConquistasDiferentes();

        final minhas = await Conquistas.deUsuario(carlos);
        final daAna = await Conquistas.deUsuario(ana);

        expect(minhas, isNotEmpty);
        expect(daAna, isNotEmpty);

        // Conjuntos diferentes. Se as duas telas lessem a mesma fonte, o
        // perfil da Ana mostraria as conquistas do usuário 1.
        expect(minhas, isNot(equals(daAna)));

        // E a sessão também lê do endpoint, pelo token.
        await Conquistas.instance.carregar();

        expect(Conquistas.instance.desbloqueadas, minhas);
      });

      test('conquista de outra pessoa é leitura, escrita é da sessão', () async {
        await garantirConquistasDiferentes();

        final conquistas = ConquistaService();

        // A de outra pessoa vai pelo id e é pública: o perfil de alguém
        // mostra o emblema dele mesmo sem conta.
        final daAna = await conquistas.buscarDesbloqueadas(ana);
        expect(daAna, isNotEmpty);

        // A própria vem do token, com `daSessao`.
        final minhas = await conquistas.buscarDesbloqueadas(
          carlos,
          daSessao: true,
        );

        expect(minhas, isNotEmpty);
      });

      test('logout revoga o token', () async {
        final token = AuthSession.instance.token;

        expect(token, isNotNull);

        await AuthService().encerrarSessao();

        // O token deixou de valer: a mesma chamada agora é recusada.
        final recusado = await AuthService().minhaConta(token: token);

        expect(recusado, isNull);

        // Reentra para o próximo teste não começar deslogado.
        await entrarComoCarlos();
      });

      test('token recusado derruba a sessão e limpa o token guardado', () async {
        expect(AuthSession.instance.logado, isTrue);

        AuthSession.instance.tokenRecusado();

        expect(AuthSession.instance.logado, isFalse);
        expect(AuthSession.instance.token, isNull);
        expect(AuthSession.instance.expirada, isTrue);
        expect(AuthSession.instance.temSessao, isFalse);

        await entrarComoCarlos();
      });
    },
    skip: AppConfig.usarApi
        ? false
        : 'precisa da API no ar: use usarApi = true e suba o conport-api',
  );
}

/// Binding de teste que deixa o `HttpClient` real: é a única forma de o
/// `flutter test` falar com a API de verdade.
class BindingRedeReal extends AutomatedTestWidgetsFlutterBinding {
  static BindingRedeReal? _instancia;

  static BindingRedeReal ensureInitialized() =>
      _instancia ??= BindingRedeReal();

  @override
  bool get overrideHttpClient => false;
}