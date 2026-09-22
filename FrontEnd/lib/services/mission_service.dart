// nao vo escrever tudo comment dnv nao, leia models/mission.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:conport/models/mission.dart';

class MissionService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String missionsEndpoint = '/missoes';

  final http.Client client;

  MissionService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Mission>> fetchWeeklyMissions() async {
    final response = await client.get(
      Uri.parse('$baseUrl$missionsEndpoint'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao buscar missões: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final content = decoded['missoes'];

      if (content is! List) {
        throw const FormatException('Formato de resposta de missões inválido.');
      }

      data = content;
    } else {
      throw const FormatException('Formato de resposta de missões inválido.');
    }

    final missions = data
        .whereType<Map<String, dynamic>>()
        .map(Mission.fromJson)
        .toList();

    if (missions.length != 3) {
      throw FormatException(
        'A API retornou ${missions.length} missões; eram esperadas 3.',
      );
    }

    return missions;
  }

  Future<List<Mission>> fetchWeeklyMissionsWithFallback() async {
    try {
      return await fetchWeeklyMissions();
    } catch (_) {
      return Mission.mock;
    }
  }

  Future<Mission> progressMission(int missionId, int amount) async {
    final response = await client.post(
      Uri.parse('$baseUrl$missionsEndpoint/$missionId/progresso'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'Progresso': amount}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao atualizar missão: HTTP ${response.statusCode}');
    }

    return Mission.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
