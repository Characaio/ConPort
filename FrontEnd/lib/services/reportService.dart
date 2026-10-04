import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:conport/config/app_config.dart';
import 'package:conport/mocks/report_mock.dart';
import 'package:conport/services/multipart_media_type.dart';
import 'package:conport/models/report.dart';
import 'package:conport/models/report_lista.dart';

class ReportService {
  final String urlBase = AppConfig.apiUrl;

  // ============================================================
  // LISTAR REPORTS DA UNIDADE
  // ============================================================

  Future<List<Report>> buscarReportsDaUnidade(int unidadeId) async {
    if (!AppConfig.usarApi) {
      return ReportMock.buscarReportsDaUnidade(unidadeId);
    }

    final url = Uri.parse('$urlBase/unidade/$unidadeId/reports');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      return json.map((item) => Report.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar reports: ${response.statusCode}');
  }

  // ============================================================
  // LISTAR MEUS REPORTS
  // ============================================================

  /// Reports enviados pelo usuário, em qualquer unidade. É o que a tela
  /// "Seus Reports" usa: não é a lista da unidade.
  Future<List<ReportLista>> buscarMeusReports(int usuarioId) async {
    if (!AppConfig.usarApi) {
      return ReportMock.buscarMeusReports();
    }

    final url = Uri.parse('$urlBase/usuarios/$usuarioId/reports');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;

      return lista
          .map((item) => ReportLista.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado.');
    }

    throw Exception('Erro ao buscar seus reports: ${response.statusCode}');
  }

  // ============================================================
  // BUSCAR REPORT ESPECÍFICO
  // ============================================================

  Future<Report> buscarReport(int unidadeId, int reportId) async {
    final url = Uri.parse('$urlBase/unidade/$unidadeId/reports/$reportId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      throw Exception('Report não encontrado');
    }

    throw Exception('Erro ao buscar report: ${response.statusCode}');
  }

  // ============================================================
  // CRIAR REPORT
  // ============================================================

  Future<Report> postarReport({
    required int unidadeId,
    required int usuarioId,
    required String tipo,
    required String descricao,
    required double urgencia,
    required DateTime dataDoOcorrido,
    double? latitude,
    double? longitude,
    List<XFile> imagens = const [],
  }) async {
    if (!AppConfig.usarApi) {
      // Simula a latência da rede enquanto o endpoint não existe.
      await Future.delayed(const Duration(milliseconds: 600));

      return ReportMock.postarReport(
        unidadeId: unidadeId,
        usuarioId: usuarioId,
        tipo: tipo,
        descricao: descricao,
        dataDoOcorrido: dataDoOcorrido,
      );
    }

    final url = Uri.parse('$urlBase/unidade/$unidadeId/reports');

    final request = http.MultipartRequest('POST', url);

    final reportDTO = {
      'Tipo': tipo,
      'Descricao': descricao,
      // O backend espera o nome da prioridade, não um número: mandar o
      // inteiro fazia o Jackson falhar e o report não era criado.
      'Prioridade': _prioridadeDe(urgencia),
      'DataDoOcorrido': dataDoOcorrido.toIso8601String(),
      'UsuarioId': usuarioId,
    };

    request.files.add(
      http.MultipartFile.fromString(
        'reportDTO',
        jsonEncode(reportDTO),
        contentType: MediaType('application', 'json'),
      ),
    );

    // Localização
    if (latitude != null && longitude != null) {
      // A origem é obrigatória no LocalizacaoDTO do backend.
      final localizacaoDTO = {
        'Latitude': latitude,
        'Longitude': longitude,
        'Origem': 'GPS_CELULAR',
      };

      request.files.add(
        http.MultipartFile.fromString(
          'localizacao',
          jsonEncode(localizacaoDTO),
          contentType: MediaType('application', 'json'),
        ),
      );
    }

    // Imagens (bytes em vez de caminho: funciona também na web)
    for (final imagem in imagens) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagens',
          await imagem.readAsBytes(),
          filename: imagem.name,
          // Sem contentType a parte do arquivo sai sem Content-Type e o
          // backend recusa a imagem com "Formato não permitido".
          contentType: mediaTypeDaImagem(imagem.name),
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Report.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Erro ao criar report: '
      '${response.statusCode} - ${response.body}',
    );
  }

  /// Converte a urgência do slider (0 a 1) no nome da prioridade que o
  /// backend espera: BAIXA, MEDIA, ALTA ou ALARMANTE.
  static String _prioridadeDe(double urgencia) {
    if (urgencia < 0.25) return 'BAIXA';
    if (urgencia < 0.5) return 'MEDIA';
    if (urgencia < 0.75) return 'ALTA';
    return 'ALARMANTE';
  }
}
