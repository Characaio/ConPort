import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/mocks/conquista_mock.dart';
import 'package:conport/models/conquista.dart';

/// Progresso de conquistas do usuário.
///
/// Com `AppConfig.usarApi == false` o progresso fica em memória
/// ([ConquistaMock]). Com a API ligada, os endpoints esperados são:
///
/// * `GET  /usuarios/{id}/conquistas`          → `["report_enviado", ...]`
/// * `POST /usuarios/{id}/conquistas/{chave}`  → 201 (409 = já desbloqueada)
class ConquistaService {
  final String urlBase = AppConfig.apiUrl;

  // ============================================================
  // QUAIS JÁ FORAM DESBLOQUEADAS
  // ============================================================

  Future<List<TipoConquista>> buscarDesbloqueadas(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return ConquistaMock.desbloqueadas(usuarioId);
    }

    final url = Uri.parse('$urlBase/usuarios/$usuarioId/conquistas');

    final response = await http.get(url);

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

    final url = Uri.parse(
      '$urlBase/usuarios/$usuarioId/conquistas/${tipo.chave}',
    );

    final response = await http.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) return;

    // Já estava desbloqueada: não é erro.
    if (response.statusCode == 409) return;

    throw Exception('Erro ao desbloquear conquista: ${response.statusCode}');
  }
}
