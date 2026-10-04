import 'dart:convert';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/session/api_client.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/mocks/notificacao_mock.dart';
import 'package:conport/models/notificacao.dart';

/// Notificações do usuário da sessão.
///
/// Com `AppConfig.usarApi == false` tudo fica em memória
/// ([NotificacaoMock]). Com a API ligada o usuário **não** vai na URL — ele vem
/// do token —, o que impede ler, apagar ou marcar como lida a notificação de
/// outra conta:
///
/// * `GET    /usuarios/eu/notificacoes`                   → todas
/// * `GET    /usuarios/eu/notificacoes/nao-lidas`          → só as não lidas
/// * `GET    /usuarios/eu/notificacoes/nao-lidas/contagem` → `{"naoLidas": 2}`
/// * `POST   /usuarios/eu/notificacoes`                   → cria (201)
/// * `PATCH  /usuarios/eu/notificacoes/{id}/ler`          → a notificação
/// * `PATCH  /usuarios/eu/notificacoes/ler-todas`         → `{"marcadas": n}`
/// * `DELETE /usuarios/eu/notificacoes/{id}`              → 204
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

    final url = Uri.parse('$urlBase/usuarios/eu/notificacoes');

    final response = await ApiClient.get(url);

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

    final url = Uri.parse('$urlBase/usuarios/eu/notificacoes/nao-lidas');

    final response = await ApiClient.get(url);

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

    final url = Uri.parse('$urlBase/usuarios/eu/notificacoes/nao-lidas/contagem');

    final response = await ApiClient.get(url);

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
      '$urlBase/usuarios/eu/notificacoes/$notificacaoId/ler',
    );

    final response = await ApiClient.patch(url);

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

    final url = Uri.parse('$urlBase/usuarios/eu/notificacoes/ler-todas');

    final response = await ApiClient.patch(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return (json['naoLidas'] as num?)?.toInt() ?? 0;
    }

    throw Exception(_erro('marcar todas como lidas', response.statusCode));
  }

  // ============================================================
  // CRIAR E EXCLUIR
  // ============================================================

  /// Cria uma notificação para quem está logado.
  ///
  /// Usada pelo app só para a conquista: os avisos de cadastro, solicitação e
  /// amizade nascem no backend, que é quem tem os dois lados do evento.
  Future<Notificacao> criar({
    required String titulo,
    required String texto,
  }) async {
    if (!AppConfig.usarApi) {
      return NotificacaoMock.criar(_idDaSessao, titulo, texto);
    }

    final url = Uri.parse('$urlBase/usuarios/eu/notificacoes');

    final response = await ApiClient.postJson(
      url,
      {'titulo': titulo, 'texto': texto},
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
      '$urlBase/usuarios/eu/notificacoes/$notificacaoId',
    );

    final response = await ApiClient.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_erro('excluir notificação', response.statusCode));
  }

  // ============================================================
  // AJUDA
  // ============================================================

  /// Chave do progresso do mock; com a API quem é a conta vem do token.
  int get _idDaSessao => AuthSession.instance.usuario?.id ?? 0;

  List<Notificacao> _lerLista(String body) {
    final json = jsonDecode(body) as List<dynamic>;

    return json
        .map((e) => Notificacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _erro(String acao, int statusCode) => 'Erro ao $acao: $statusCode';
}