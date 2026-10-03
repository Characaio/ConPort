import 'package:conport/models/usuario.dart';
import 'package:conport/mocks/usuario_mock.dart';

/// Login e cadastro usados quando `AppConfig.usarApi` é `false`.
///
/// Mantém as contas em memória: a conta demo sempre existe e as contas
/// criadas no cadastro valem até o app fechar. [reiniciar] volta tudo ao
/// estado inicial (usado nos testes).
class AuthMock {
  AuthMock._();

  /// Conta de demonstração aceita pelo login.
  static const String emailDemo = 'demo@conport.com';
  static const String senhaDemo = '123456';

  static final List<Usuario> _contas = [_demo];

  static int _proximoId = 1000;

  /// Mesmo usuário do UsuarioMock (id 2, o mesmo usado pelo app).
  static Usuario get _demo => UsuarioMock.pegarDados(2);

  static Future<Usuario?> entrar({
    required String email,
    required String senha,
  }) async {
    await _latencia();

    final alvo = email.trim().toLowerCase();

    for (final conta in _contas) {
      if (conta.email.toLowerCase() == alvo && conta.senha == senha) {
        return conta;
      }
    }

    return null;
  }

  static Future<Usuario?> cadastrar({
    required String nome,
    required String username,
    required String email,
    required String senha,
    required DateTime dataNasc,
    required String estado,
    required String cidade,
  }) async {
    await _latencia();

    final alvo = email.trim().toLowerCase();

    if (_contas.any((conta) => conta.email.toLowerCase() == alvo)) {
      return null;
    }

    final usuario = Usuario(
      id: _proximoId++,
      nome: nome.trim(),
      username: username.trim().toLowerCase(),
      // O backend define a regra; o mock só preenche uma data válida.
      datanasc: dataNasc,
      estado: estado.trim(),
      cidade: cidade.trim(),
      email: alvo,
      senha: senha,
      confiavel: false,
      xp: 0,
      level: 1,
      moedas: 0,
      reportsEnviados: 0,
      reportsResolvidos: 0,
      reportsRejeitados: 0,
      reportsPendentes: 0,
      missoesConcluidas: 0,
    );

    _contas.add(usuario);

    return usuario;
  }

  /// Simula o tempo de resposta do servidor.
  static Future<void> _latencia() =>
      Future.delayed(const Duration(milliseconds: 400));

  /// Volta as contas ao estado inicial.
  static void reiniciar() {
    _contas
      ..clear()
      ..add(_demo);
    _proximoId = 1000;
  }
}
