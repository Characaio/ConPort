import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/mocks/notificacao_mock.dart';
import 'package:conport/models/notificacao.dart';

/// Notificações do usuário.
///
/// Com `AppConfig.usarApi == false` tudo fica em memória
/// ([NotificacaoMock]). Com a API ligada, os endpoints são:
///
/// * `GET    /usuarios/{id}/notificacoes`                   → todas
/// * `GET    /usuarios/{id}/notificacoes/nao-lidas`          → só as não lidas
/// * `GET    /usuarios/{id}/notificacoes/nao-lidas/contagem` → `{"naoLidas": 2}`
/// * `POST   /usuarios/{id}/notificacoes`                   → cria (201)
/// * `PATCH  /usuarios/{id}/notificacoes/{id}/ler`          → a notificação
/// * `PATCH  /usuarios/{id}/notificacoes/ler-todas`         → `{"marcadas": n}`
/// * `DELETE /usuarios/{id}/notificacoes/{id}`              → 204
class NotificacaoService {
  final String urlBase = AppConfig.apiUrl;

  // ============================================================
  // LISTAR
  // ============================================================

  /// Todas as notificações, da mais recente para a mais antiga.
  Future<List<Notificacao>> listar(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return NotificacaoMock.listar(usuarioId);
    }

    final url = Uri.parse('$urlBase/usuarios/$usuarioId/notificacoes');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return _lerLista(response.body);
    }

    throw Exception(_erro('buscar notificações', response.statusCode));
  }

  /// Só as não lidas (o que o sino do topo da tela mostra).
  Future<List<Notificacao>> listarNaoLidas(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return NotificacaoMock.listarNaoLidas(usuarioId);
    }

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/notificacoes/nao-lidas',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return _lerLista(response.body);
    }

    throw Exception(_erro('buscar notificações não lidas', response.statusCode));
  }

  /// Só o número do badge, sem baixar título e texto de cada uma.
  Future<int> contarNaoLidas(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return NotificacaoMock.contarNaoLidas(usuarioId);
    }

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/notificacoes/nao-lidas/contagem',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return (json['naoLidas'] as num?)?.toInt() ?? 0;
    }

    throw Exception(_erro('contar notificações', response.statusCode));
  }

  // ============================================================
  // MARCAR COMO LIDA
  // ============================================================

  /// Marca uma notificação como lida e devolve ela já lida.
  ///
  /// O backend devolve a notificação atualizada justamente para a tela
  /// substituir a da lista sem precisar adivinhar o que mudou.
  Future<Notificacao> marcarComoLida(int usuarioId, int notificacaoId) async {
    if (!AppConfig.usarApi) {
      return NotificacaoMock.marcarComoLida(usuarioId, notificacaoId);
    }

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/notificacoes/$notificacaoId/ler',
    );

    final response = await http.patch(url);

    if (response.statusCode == 200) {
      return Notificacao.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_erro('marcar notificação como lida', response.statusCode));
  }

  /// Marca todas como lidas e devolve o total atualizado de não lidas.
  Future<int> marcarTodasComoLidas(int usuarioId) async {
    if (!AppConfig.usarApi) {
      NotificacaoMock.marcarTodasComoLidas(usuarioId);

      return 0;
    }

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/notificacoes/ler-todas',
    );

    final response = await http.patch(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return (json['naoLidas'] as num?)?.toInt() ?? 0;
    }

    throw Exception(_erro('marcar todas como lidas', response.statusCode));
  }

  // ============================================================
  // CRIAR E EXCLUIR
  // ============================================================

  /// Cria uma notificação para o usuário.
  ///
  /// Usada pelo app só para a conquista: os avisos de cadastro, solicitação e
  /// amizade nascem no backend, que é quem tem os dois lados do evento.
  Future<Notificacao> criar(
    int usuarioId, {
    required String titulo,
    required String texto,
  }) async {
    if (usuarioId == 0) {
      throw Exception('Notificação só existe para usuário logado.');
    }

    if (!AppConfig.usarApi) {
      return NotificacaoMock.criar(usuarioId, titulo, texto);
    }

    final url = Uri.parse('$urlBase/usuarios/$usuarioId/notificacoes');

    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'titulo': titulo, 'texto': texto}),
    );

    if (response.statusCode == 201) {
      return Notificacao.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_erro('criar notificação', response.statusCode));
  }

  /// Exclui uma notificação (204 = deu certo).
  Future<void> excluir(int usuarioId, int notificacaoId) async {
    if (!AppConfig.usarApi) {
      NotificacaoMock.excluir(usuarioId, notificacaoId);
      return;
    }

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/notificacoes/$notificacaoId',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_erro('excluir notificação', response.statusCode));
  }

  // ============================================================
  // AJUDA
  // ============================================================

  List<Notificacao> _lerLista(String body) {
    final json = jsonDecode(body) as List<dynamic>;

    return json
        .map((e) => Notificacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _erro(String acao, int statusCode) => 'Erro ao $acao: $statusCode';
}
