import 'package:flutter/material.dart';

import 'package:conport/models/usuario.dart';

/// Quem está usando o app agora: um usuário logado ou um visitante
/// ("explorar sem conta").
///
/// Por enquanto a sessão vive só em memória. Para ligar na API, guarde o
/// [token] devolvido pelo login e carregue de volta aqui na inicialização
/// (o campo já existe para isso).
class AuthSession extends ChangeNotifier {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  Usuario? _usuario;
  String? _token;
  bool _visitante = false;

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

  void entrar(Usuario usuario, {String? token}) {
    _usuario = usuario;
    _token = token;
    _visitante = false;
    notifyListeners();
  }

  void entrarComoVisitante() {
    _usuario = null;
    _token = null;
    _visitante = true;
    notifyListeners();
  }

  void encerrar() {
    _usuario = null;
    _token = null;
    _visitante = false;
    notifyListeners();
  }
}
