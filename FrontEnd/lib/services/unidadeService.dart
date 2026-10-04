import 'dart:convert';

import 'package:conport/models/report.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/unidade.dart';
import '../mocks/unidade_mock.dart';

class UnidadeService {
  const UnidadeService();

  Future<Unidade> buscarStatusPrincipal(int id) async {
    if (!AppConfig.usarApi) {
      return UnidadeMock.buscarStatusPrincipal(id);
    }

    final url = Uri.parse('${AppConfig.apiUrl}/unidade/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Unidade.fromJson(json);
    }

    if (response.statusCode == 404) {
      throw Exception('Unidade não encontrada');
    }

    throw Exception('Erro ao buscar unidade: ${response.statusCode}');
  }

  /// Status geral da unidade: informacoes + indicadores + dados ambientais.
  Future<Unidade> buscarStatusGeral(int id) async {
    if (!AppConfig.usarApi) {
      return UnidadeMock.buscarStatusPrincipal(id);
    }

    // A rota do status geral e GET /unidade/{id} (a informacoes fica em
    // /unidade/{id}/informacoes); o nome statusGeral nao existe no backend.
    final url = Uri.parse('${AppConfig.apiUrl}/unidade/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Unidade.fromJson(json);
    }

    if (response.statusCode == 404) {
      throw Exception('Unidade não encontrada');
    }

    throw Exception('Erro ao buscar geral: ${response.statusCode}');
  }

  Future<List<Report>> buscarReports(int unidadeId) async {
    if (!AppConfig.usarApi) {
      return [];
    }

    final url = Uri.parse('${AppConfig.apiUrl}/unidade/$unidadeId/reports');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      return json.map((item) => Report.fromJson(item)).toList();
    }

    if (response.statusCode == 404) {
      throw Exception('Unidade não encontrada');
    }

    throw Exception('Erro ao buscar reports: ${response.statusCode}');
  }
}
