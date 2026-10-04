import 'dart:async';

import 'package:flutter/material.dart';

import 'package:conport/core/session/token_store.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/auth_service.dart';

/// Como a inicialização descobre se o token guardado ainda vale.
///
/// Recebe o token porque ele ainda não é a sessão: quem está chamando é o
/// [AuthSession.restaurar], que só-promove o token depois que a resposta vem.
/// Devolve `null` quando o token foi recusado (expirado ou revogado).
typedef SondaDeSessao = Future<Usuario?> Function(String token);

/// Quem está usando o app agora: um usuário logado ou um visitante
/// ("explorar sem conta").
///
/// A sessão tem duas metades: o [token] (que prova quem é, para o backend) e
/// o [usuario] (que preenche a tela). O token sobrevive ao fechamento do app no
/// cofre do sistema ([TokenStore]); o usuário é sempre rebaixado a partir
/// dele por [restaurar], porque um cache de perfil guardado em disco envelhece
/// mal e é o backend quem tem a verdade.
class AuthSession extends ChangeNotifier {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  Usuario? _usuario;
  String? _token;
  bool _visitante = false;
  bool _expirada = false;

  /// Usuário logado; `null` para quem está visitando sem conta.
  Usuario? get usuario => _usuario;

  /// Token devolvido pela API; `null` no modo mockado.
  String? get token => _token;

  /// O usuário pulou o login e está só navegando.
  bool get visitante => _visitante;

  /// Fez login de verdade (não é visitante).
  bool get logado => _usuario != null;

  /// Existe uma sessão, logada ou de visitante.
  bool get temSessao => _usuario != null || _visitante;

  /// A sessão foi derrubada porque o servidor recusou o token.
  ///
  /// A tela de acesso usa isso para explicar o sumiço em vez de só voltar
  /// para o login sem dizer nada.
  bool get expirada => _expirada;

  /// Tenta recuperar a sessão de quem entrou numa execução anterior do app.
  ///
  /// [sonda] é quem conversa com o servidor — ela vem de fora para esta
  /// biblioteca não depender do serviço de autenticação (e para o teste poder
  /// passar um dublê). Devolve `true` quando a pessoa entrou direto para o
  /// app, sem passar pela tela de acesso.
  ///
  /// Três desfechos, todos diferentes de propósito:
  ///
  /// * token guardado e aceito → sessão montada;
  /// * token guardado e recusado → o token é apagado, porque guardar um token
  ///   morto só faz o app tentar de novo a cada abertura;
  /// * token guardado mas o servidor não respondeu (sem rede, API fora) → a
  ///   sessão fica sem dono e o token é **mantido**, para a próxima abertura
  ///   não exigir login de novo.
  ///
  /// Nunca trava e nunca lança: além do [limite], tudo aqui é cercado de
  /// `try`. Quem chama é a tela de abertura, e prender essa tela deixaria a
  /// pessoa olhando o carregamento para sempre — o desfecho ruim aceitável é
  /// abrir o app sem sessão.
  Future<bool> restaurar({
    required SondaDeSessao sonda,
    Duration limite = const Duration(seconds: 10),
  }) async {
    try {
      return await _restaurar(sonda).timeout(limite);
    } on TimeoutException {
      // Nem o cofre nem o servidor responderam a tempo. Seguir sem sessão é o
      // que destrava a abertura; o token continua guardado, então a próxima
      // execução tenta de novo.
      debugPrint('SESSAO restauração não respondeu em ${limite.inSeconds}s');

      return false;
    } catch (e) {
      // Não foi o servidor recusar o token, foi a rede não responder: manter
      // o token é o que evita obrigar a pessoa a entrar de novo amanhã.
      debugPrint('SESSAO ERRO ao restaurar: $e');

      return false;
    }
  }

  /// Caminho feliz da [restaurar], sem limite de tempo nem tratamento: quem
  /// envolve é ela, para o cofre também estar coberto pelo `try`.
  Future<bool> _restaurar(SondaDeSessao sonda) async {
    final guardado = await TokenStore.instancia.ler();

    if (guardado == null || guardado.isEmpty) return false;

    final usuario = await sonda(guardado);

    if (usuario == null) {
      await TokenStore.instancia.apagar();

      return false;
    }

    _usuario = usuario;
    _token = guardado;
    _visitante = false;
    _expirada = false;
    notifyListeners();

    return true;
  }

  void entrar(Usuario usuario, {String? token}) {
    _usuario = usuario;
    _token = token;
    _visitante = false;
    _expirada = false;
    notifyListeners();

    // Gravação em segundo plano: [entrar] é síncrona porque quem chama já
    // está desenhando a tela, e esperar o cofre do sistema atrasaria a
    // entrada de todo mundo. A gravação não pode falhar de forma visível
    // (no máximo a pessoa entra de novo na próxima vez), e o [TokenStore]
    // cuida de não deixar a exceção escapar.
    if (token != null) {
      unawaited(TokenStore.instancia.gravar(token));
    }
  }

  void entrarComoVisitante() {
    _usuario = null;
    _token = null;
    _visitante = true;
    _expirada = false;

    // Visitante não é sessão de verdade: o token anterior (de outra conta,
    // talvez) sai do cofre, senão a próxima abertura ressuscita a conta que a
    // pessoa acabou de deixar.
    unawaited(TokenStore.instancia.apagar());

    notifyListeners();
  }

  /// Esquece a sessão na memória e no cofre. Não fala com o servidor.
  ///
  /// Use [sairDaConta] quando for o logout tocado na tela.
  void encerrar() {
    _usuario = null;
    _token = null;
    _visitante = false;
    _expirada = false;

    unawaited(TokenStore.instancia.apagar());

    notifyListeners();
  }

  /// Logout de verdade: revoga o token no servidor e limpa a sessão.
  ///
  /// O servidor é avisado primeiro e o erro é engolido de propósito: se a
  /// rede caiu, a pessoa quer sair da conta mesmo assim, e segurar a saída
  /// por causa de um 500 seria pior do que deixar um token vivo no servidor
  /// até ele expirar.
  Future<void> sairDaConta() async {
    await AuthService().encerrarSessao();
    encerrar();
  }

  /// "Sair de todos os lugares": revoga as outras sessões da conta também.
  Future<void> sairDeTodosOsLugares() async {
    await AuthService().encerrarSessao(emTodosOsLugares: true);
    encerrar();
  }

  /// O servidor recusou o token (401) numa chamada autenticada.
  ///
  /// Só marca [expirada] quando havia alguém logado: na abertura do app o
  /// token guardado pode ser velho sem que isso seja uma sessão que "caiu".
  void tokenRecusado() {
    if (_usuario == null) return;

    final avisar = !_expirada;

    _usuario = null;
    _token = null;
    _visitante = false;
    _expirada = true;

    unawaited(TokenStore.instancia.apagar());

    notifyListeners();

    if (avisar) debugPrint('SESSAO token recusado pelo servidor');
  }
}