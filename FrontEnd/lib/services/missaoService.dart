import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/models/mission.dart';

class MissaoService {
  final String UrlBase = AppConfig.apiUrl;

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
      throw Exception('Missao não encontrada');
    }

    throw Exception('Erro ao buscar Missao: ${response.statusCode}');
  }

  Future<List<Mission>> buscarMissoesDeUsuario(List<int> idMissoes) async {
    List<Mission> missoes = [];

    for (final id in idMissoes) {
      missoes.add(await buscarMissao(id));
    }

    return missoes;
  }

  Future<Mission> progredirMissao(int missaoId, int progresso) async {
    if (!AppConfig.usarApi) {
      return Mission.mock.firstWhere(
        (missao) => missao.id == missaoId,
        orElse: () => Mission.mock.first,
      );
    }

    final url = Uri.parse('$UrlBase/missoes/$missaoId/progresso');

    final response = await http.post(url, body: {'progresso': progresso});

    if (response.statusCode == 200) {
      return Mission.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      throw Exception('Missão não encontrada');
    }

    throw Exception('Erro ao progredir missão: ${response.statusCode}');
  }
}
