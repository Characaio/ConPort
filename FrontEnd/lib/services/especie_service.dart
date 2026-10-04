import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/mocks/especie_mock.dart';
import 'package:conport/models/especie.dart';

/// Espécies registradas na unidade.
///
/// O backend separa por tipo: a tela pede fauna e flora para montar as duas
/// grades.
class EspecieService {
  const EspecieService();

  Future<List<Especie>> listar(int unidadeId, TipoEspecie tipo) async {
    if (!AppConfig.usarApi) {
      return EspecieMock.listar(unidadeId)
          .where((e) => e.tipo == tipo)
          .toList();
    }

    final tipoNaApi = tipo == TipoEspecie.flora ? 'FLORA' : 'FAUNA';

    final url = Uri.parse(
      '${AppConfig.apiUrl}/unidade/$unidadeId/especies?tipo=$tipoNaApi',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;

      return lista
          .map((item) => Especie.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 404) {
      throw Exception('Unidade não encontrada.');
    }

    throw Exception('Erro ao buscar espécies: ${response.statusCode}');
  }
}