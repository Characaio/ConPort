import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:conport/models/report.dart';

class ReportService {
  final String UrlBase = 'http://localhost:8080';

  // ============================================================
  // BUSCAR REPORT COMPLETO
  // ============================================================

  Future<Report> buscarReportCompleto(int id) async {
    final url = Uri.parse(
      '$UrlBase/reports/$id/completo',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Report.fromJson(
        jsonDecode(response.body),
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Report não encontrado');
    }

    throw Exception(
      'Erro ao buscar Report: ${response.statusCode}',
    );
  }

  // ============================================================
  // BUSCAR REPORT RESUMIDO
  // ============================================================

  Future<Report> buscarReportResumido(int id) async {
    final url = Uri.parse(
      '$UrlBase/reports/$id/resumido',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Report.fromJson(
        jsonDecode(response.body),
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Report não encontrado');
    }

    throw Exception(
      'Erro ao buscar Report: ${response.statusCode}',
    );
  }

  // ============================================================
  // CRIAR REPORT
  // ============================================================

  Future<Report> postarReport({
    required int unidadeId,
    required int usuarioId,
    required String tipo,
    required String descricao,
    required DateTime dataDoOcorrido,
    List<String> caminhosDasImagens = const [],
  }) async {
    final url = Uri.parse(
      '$UrlBase/unidade/$unidadeId/criarReport',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    // ----------------------------------------------------------
    // DADOS DO REPORT
    // ----------------------------------------------------------

    final reportDTO = {
      'Tipo': tipo,
      'Descricao': descricao,
      'ImagensAnexadas': [],
      'DataDoOcorrido': dataDoOcorrido.toIso8601String(),
      'UsuarioId': usuarioId,
    };

    request.files.add(
      http.MultipartFile.fromString(
        'reportDTO',
        jsonEncode(reportDTO),
        contentType: MediaType(
          'application',
          'json',
        ),
      ),
    );

    // ----------------------------------------------------------
    // IMAGENS
    // ----------------------------------------------------------

    for (final caminho in caminhosDasImagens) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagens',
          caminho,
        ),
      );
    }

    // ----------------------------------------------------------
    // ENVIA PARA A API
    // ----------------------------------------------------------

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    // ----------------------------------------------------------
    // RESPOSTA DA API
    // ----------------------------------------------------------

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Report.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Erro ao postar Report: '
      '${response.statusCode} - ${response.body}',
    );
  }
}