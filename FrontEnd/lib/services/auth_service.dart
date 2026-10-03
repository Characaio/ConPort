import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/mocks/auth_mock.dart';
import 'package:conport/models/usuario.dart';

/// Erro de autenticação com mensagem pronta para mostrar na tela.
class AuthException implements Exception {
  final String mensagem;

  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// O que login e cadastro devolvem: o usuário e, com a API, o token.
class ResultadoAutenticacao {
  final Usuario usuario;
  final String? token;

  const ResultadoAutenticacao({required this.usuario, this.token});
}

/// Login e cadastro.
///
/// Com `AppConfig.usarApi == false` usa o [AuthMock]; quando a API for
/// ligada, os métodos abaixo já apontam para os endpoints do backend:
///
/// * `POST /usuarios/login`   → corpo `LoginDTO { email, senha }`,
///   devolve `UsuarioDTO` (200) ou 401/404.
/// * `POST /usuarios/signup`  → corpo `SignupDTO { nome, dataNasc, email,
///   senha, estado, cidade }`, devolve 201 sem corpo; por isso o cadastro
///   entra em seguida pelo próprio login.
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

    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'senha': senha}),
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

    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome.trim(),
        'username': username.trim().toLowerCase(),
        'dataNasc': _dataIso(dataNasc),
        'email': email.trim(),
        'senha': senha,
        'estado': estado.trim(),
        'cidade': cidade.trim(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // O cadastro do backend responde 201 sem corpo: entra em seguida.
      if (response.body.trim().isEmpty) {
        return entrar(email: email, senha: senha);
      }

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
  // RESPOSTA
  // ============================================================

  /// Aceita tanto `{"token": "...", "usuario": {...}}` quanto o próprio
  /// `UsuarioDTO` solto, que é o que o backend devolve hoje.
  ResultadoAutenticacao _lerResposta(String corpo) {
    final dynamic json = jsonDecode(corpo);

    if (json is! Map) {
      throw const AuthException('Resposta inválida do servidor.');
    }

    final dados = Map<String, dynamic>.from(json);
    final dynamic usuarioJson =
        dados['usuario'] ?? dados['Usuario'] ?? dados['user'] ?? dados;

    if (usuarioJson is! Map) {
      throw const AuthException('Resposta inválida do servidor.');
    }

    return ResultadoAutenticacao(
      usuario: Usuario.fromJson(Map<String, dynamic>.from(usuarioJson)),
      token: dados['token']?.toString() ?? dados['Token']?.toString(),
    );
  }

  /// `LocalDate` do Java: só a data, `aaaa-mm-dd`.
  String _dataIso(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '${data.year.toString().padLeft(4, '0')}-$mes-$dia';
  }
}
