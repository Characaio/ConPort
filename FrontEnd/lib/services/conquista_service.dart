import 'dart:convert';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/session/api_client.dart';
import 'package:conport/mocks/conquista_mock.dart';
import 'package:conport/models/conquista.dart';

/// Progresso de conquistas.
///
/// Com `AppConfig.usarApi == false` o progresso fica em memória
/// ([ConquistaMock]). Com a API ligada:
///
/// * `GET  /usuarios/eu/conquistas`          → `["report_enviado", ...]`
///   As conquistas da **sua** conta: é o que a sua tela mostra e o que o
///   desbloqueio escreve, sempre pela sessão (nunca por id na URL).
/// * `GET  /usuarios/{id}/conquistas`        → só leitura, para o perfil de
///   outra pessoa. É informação pública do perfil (um emblema), mas quem
///   desbloqueia é só a própria conta.
/// * `POST /usuarios/eu/conquistas/{chave}`  → 201 (409 = já desbloqueada)
class ConquistaService {
  final String urlBase = AppConfig.apiUrl;

  // ============================================================
  // QUAIS JÁ FORAM DESBLOQUEADAS
  // ============================================================

  /// Conquistas de [usuarioId].
  ///
  /// [daSessao] escolhe a rota: a sua própria passa por `/eu` (o servidor
  /// descobre quem é pelo token), a de outra pessoa passa pelo id. No modo
  /// mock é sempre o id, porque o mock é local e precisa da chave.
  Future<List<TipoConquista>> buscarDesbloqueadas(
    int usuarioId, {
    bool daSessao = false,
  }) async {
    if (!AppConfig.usarApi) {
      return ConquistaMock.desbloqueadas(usuarioId);
    }

    final url = daSessao
        ? Uri.parse('$urlBase/usuarios/eu/conquistas')
        : Uri.parse('$urlBase/usuarios/$usuarioId/conquistas');

    final response = await ApiClient.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final tipos = <TipoConquista>[];

      for (final item in json) {
        final tipo = TipoConquista.porChave(item.toString());

        // Chave desconhecida (app desatualizado): ignora.
        if (tipo != null) tipos.add(tipo);
      }

      return tipos;
    }

    throw Exception('Erro ao buscar conquistas: ${response.statusCode}');
  }

  // ============================================================
  // DESBLOQUEAR
  // ============================================================

  Future<void> desbloquear(int usuarioId, TipoConquista tipo) async {
    if (!AppConfig.usarApi) {
      ConquistaMock.desbloquear(tipo, usuarioId);
      return;
    }

    final url = Uri.parse('$urlBase/usuarios/eu/conquistas/${tipo.chave}');

    final response = await ApiClient.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) return;

    // Já estava desbloqueada: não é erro.
    if (response.statusCode == 409) return;

    throw Exception('Erro ao desbloquear conquista: ${response.statusCode}');
  }
}