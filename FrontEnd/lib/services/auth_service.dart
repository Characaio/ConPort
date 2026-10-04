import 'dart:convert';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/session/api_client.dart';
import 'package:conport/mocks/auth_mock.dart';
import 'package:conport/models/usuario.dart';

/// Erro de autenticação com mensagem pronta para mostrar na tela.
class AuthException implements Exception {
  final String mensagem;

  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// O que login e cadastro devolvem: o usuário e o token da sessão.
///
/// Com a API, o backend responde `SessaoDTO { Token, Usuario }`: quem entra
/// já sai com o token na mão e não precisa trocar de novo por causa do
/// `/login`. No modo mock não existe token — o progresso dos mocks é local.
class ResultadoAutenticacao {
  final Usuario usuario;
  final String? token;

  const ResultadoAutenticacao({required this.usuario, this.token});
}

/// Login, cadastro e o fim da sessão.
///
/// Com `AppConfig.usarApi == false` usa o [AuthMock]; com a API ligada, os
/// endpoints são:
///
/// * `POST /usuarios/login`  → corpo `LoginDTO { email, senha }` → 200
///   `SessaoDTO { Token, Usuario }`, ou 401 (e-mail errado e senha errada
///   devolvem a mesma coisa, para não revelar quais e-mails existem).
/// * `POST /usuarios/signup` → corpo `SignupDTO { nome, username, dataNasc,
///   email, senha, estado, cidade }` → 201 `SessaoDTO`, 409 e-mail repetido,
///   400 senha curta.
/// * `GET    /usuarios/eu`   → o perfil de quem tem o token, ou 401.
/// * `POST   /usuarios/logout`, `POST /usuarios/logout-em-todos-os-lugares`
///   → revogam o token (204).
class AuthService {
  final String urlBase = AppConfig.apiUrl;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<ResultadoAutenticacao> entrar({
    required String email,
    required String senha,
  }) async {
    if (!AppConfig.usarApi) {
      final usuario = await AuthMock.entrar(email: email, senha: senha);

      if (usuario == null) {
        throw const AuthException('E-mail ou senha incorretos.');
      }

      return ResultadoAutenticacao(usuario: usuario);
    }

    final url = Uri.parse('$urlBase/usuarios/login');

    final response = await ApiClient.postJson(
      url,
      {'email': email.trim(), 'senha': senha},
    );

    if (response.statusCode == 200) {
      return _lerResposta(response.body);
    }

    if (response.statusCode == 401 || response.statusCode == 404) {
      throw const AuthException('E-mail ou senha incorretos.');
    }

    throw AuthException('Erro ao entrar (${response.statusCode}).');
  }

  // ============================================================
  // CADASTRO
  // ============================================================

  Future<ResultadoAutenticacao> cadastrar({
    required String nome,
    required String username,
    required String email,
    required String senha,
    required DateTime dataNasc,
    required String estado,
    required String cidade,
  }) async {
    if (!AppConfig.usarApi) {
      final usuario = await AuthMock.cadastrar(
        nome: nome,
        username: username,
        email: email,
        senha: senha,
        dataNasc: dataNasc,
        estado: estado,
        cidade: cidade,
      );

      if (usuario == null) {
        throw const AuthException('Este e-mail já está cadastrado.');
      }

      return ResultadoAutenticacao(usuario: usuario);
    }

    final url = Uri.parse('$urlBase/usuarios/signup');

    final response = await ApiClient.postJson(
      url,
      {
        'nome': nome.trim(),
        'username': username.trim().toLowerCase(),
        'dataNasc': _dataIso(dataNasc),
        'email': email.trim(),
        'senha': senha,
        'estado': estado.trim(),
        'cidade': cidade.trim(),
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _lerResposta(response.body);
    }

    if (response.statusCode == 409) {
      throw const AuthException('Este e-mail já está cadastrado.');
    }

    if (response.statusCode == 400) {
      throw const AuthException('Confira os dados informados.');
    }

    throw AuthException('Erro ao criar a conta (${response.statusCode}).');
  }

  // ============================================================
  // SESSÃO
  // ============================================================

  /// Prova um token guardado e devolve o dono dele.
  ///
  /// É o que a abertura do app chama: `null` significa token recusado (expirado
  /// ou revogado) e a pessoa volta para a tela de acesso. Sem API ligada não há
  /// token para provar — o modo demonstração guarda o progresso em memória.
  static Future<Usuario?> validarToken(String token) async {
    if (!AppConfig.usarApi) return null;

    final usuario = await AuthService().minhaConta(token: token);

    return usuario;
  }

  /// `GET /usuarios/eu`: o perfil de quem está com o token.
  ///
  /// [token] existe para a sondagem de abertura, em que o token ainda não é a
  /// sessão. O 401 vira `null` (token recusado) em vez de exceção: quem decide
  /// o que fazer com isso é o [AuthSession], e para a tela tanto faz.
  Future<Usuario?> minhaConta({String? token}) async {
    if (!AppConfig.usarApi) return null;

    final url = Uri.parse('$urlBase/usuarios/eu');

    final response = await ApiClient.get(url, token: token);

    if (response.statusCode == 200) {
      return Usuario.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    return null;
  }

  /// Revoga o token no servidor.
  ///
  /// Não lança exceção de propósito: quem chama é o botão de sair, e falhar
  /// o logout por causa da rede prenderia a pessoa logada no app.
  Future<void> encerrarSessao({bool emTodosOsLugares = false}) async {
    if (!AppConfig.usarApi) return;

    final rota = emTodosOsLugares
        ? 'logout-em-todos-os-lugares'
        : 'logout';

    try {
      await ApiClient.post(Uri.parse('$urlBase/usuarios/$rota'));
    } catch (_) {
      // Sem rede o token continua válido no servidor até expirar; a sessão
      // local é limpa de qualquer jeito.
    }
  }

  // ============================================================
  // RESPOSTA
  // ============================================================

  /// Lê o `SessaoDTO { Token, Usuario }`.
  ///
  /// O backend grava em PascalCase (o nome dos campos do Java), mas o app
  /// aceita as duas grafias: se um dia o JSON sair com nome minúsculo, o
  /// login continua funcionando em vez de virar "Resposta inválida".
  ResultadoAutenticacao _lerResposta(String corpo) {
    final dynamic json = jsonDecode(corpo);

    if (json is! Map) {
      throw const AuthException('Resposta inválida do servidor.');
    }

    final dados = Map<String, dynamic>.from(json);
    final dynamic usuarioJson =
        dados['Usuario'] ?? dados['usuario'] ?? dados['user'];

    if (usuarioJson is! Map) {
      throw const AuthException('Resposta inválida do servidor.');
    }

    return ResultadoAutenticacao(
      usuario: Usuario.fromJson(Map<String, dynamic>.from(usuarioJson)),
      token: dados['Token']?.toString() ?? dados['token']?.toString(),
    );
  }

  /// `LocalDate` do Java: só a data, `aaaa-mm-dd`.
  String _dataIso(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '${data.year.toString().padLeft(4, '0')}-$mes-$dia';
  }
}