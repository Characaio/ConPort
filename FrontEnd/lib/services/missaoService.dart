import 'dart:convert';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/session/api_client.dart';
import 'package:conport/models/mission.dart';

/// Missões da sessão.
///
/// Com a API o progresso é do usuário do token: a listagem saiu do
/// `?usuarioId=` — que deixava qualquer um ver e mexer no progresso de qualquer
/// conta — e as rotas passaram a exigir sessão.
class MissaoService {
  final String UrlBase = AppConfig.apiUrl;

/// Lista as missões de quem está logado. É o que a tela de missões usa.
Future<List<Mission>> listarMissoes() async {
    if (!AppConfig.usarApi) {
      return Mission.mock;
    }

    final url = Uri.parse('$UrlBase/missoes');

    final response = await ApiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return (json as List)
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar missões: ${response.statusCode}');
  }

  Future<Mission> buscarMissao(int missaoId) async {
    if (!AppConfig.usarApi) {
      return Mission.mock.firstWhere(
        (missao) => missao.id == missaoId,
        orElse: () => Mission.mock.first,
      );
    }

    final url = Uri.parse('$UrlBase/missoes/$missaoId');

    final response = await ApiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Mission.fromJson(json);
    }

    if (response.statusCode == 404) {
      throw Exception('Missão não encontrada.');
    }

    throw Exception('Erro ao buscar missão: ${response.statusCode}');
  }

  Future<Mission> progredirMissao(int missaoId, int progresso) async {
    if (!AppConfig.usarApi) {
      return Mission.mock.firstWhere(
        (missao) => missao.id == missaoId,
        orElse: () => Mission.mock.first,
      );
    }

    final url = Uri.parse('$UrlBase/missoes/$missaoId/progresso');

    // O backend espera JSON, não form data.
    final response = await ApiClient.postJson(url, {'progresso': progresso});

    if (response.statusCode == 200) {
      return Mission.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      throw Exception('Missão não encontrada.');
    }

    if (response.statusCode == 409) {
      throw Exception(
        jsonDecode(response.body).toString().contains('concluída') == true
            ? 'Esta missão já foi concluída.'
            : 'Esta missão não pode mais ser avançada.',
      );
    }

    throw Exception('Erro ao progredir missão: ${response.statusCode}');
  }
}