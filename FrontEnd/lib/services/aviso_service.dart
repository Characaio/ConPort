import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/models/aviso.dart';
import 'package:conport/mocks/aviso_mock.dart';

/// Anúncios da unidade de conservação.
///
/// O backend limita a lista por quantidade: `limite=1` traz só o mais
/// recente (é o que o mapa usa), `limite=50` traz a lista da tela.
class AvisoService {
  const AvisoService();

  Future<List<Aviso>> listarAvisos(int unidadeId, {int limite = 50}) async {
    if (!AppConfig.usarApi) {
      return AvisoMock.listar(unidadeId).take(limite).toList();
    }

    final url = Uri.parse(
      '${AppConfig.apiUrl}/unidade/$unidadeId/aviso?limite=$limite',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;

      return lista
          .map((item) => Aviso.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 404) {
      throw Exception('Unidade não encontrada.');
    }

    throw Exception('Erro ao buscar anúncios: ${response.statusCode}');
  }

  /// Aviso mais recente, usado na gaveta do mapa.
  Future<Aviso?> buscarMaisRecente(int unidadeId) async {
    final avisos = await listarAvisos(unidadeId, limite: 1);

    return avisos.isEmpty ? null : avisos.first;
  }
}