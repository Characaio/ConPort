import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/models/mission.dart';

class MissaoService {
  final String UrlBase = AppConfig.apiUrl;

  /// Lista as missões de um usuário. É o que a tela de missões usa.
  Future<List<Mission>> listarMissoes(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return Mission.mock;
    }

    final url = Uri.parse(
      '$UrlBase/missoes',
    ).replace(queryParameters: {'usuarioId': '$usuarioId'});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return (json as List)
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado.');
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

    final response = await http.get(url);

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
    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'progresso': progresso}),
    );

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