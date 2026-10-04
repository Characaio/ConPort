import 'dart:convert';

import 'package:conport/core/session/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'multipart_media_type.dart';

import '../config/app_config.dart';

/// Avistamento da sessão.
///
/// O autor sai do token: o DTO não tem mais `UsuarioId`, então não existe mais
/// como registrar avistamento em nome de outra pessoa nem em nome de ninguém
/// (sem sessão a chamada volta 401).
class AvistamentoService {
  const AvistamentoService();

  Future<void> enviar({
    required XFile imagem,
    required int unidadeId,
    double? latitude,
    double? longitude,
  }) async {
    if (!AppConfig.usarApi) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${AppConfig.apiUrl}/unidade/$unidadeId/avistamento',
      ),
    );

    final dto = <String, dynamic>{
      'UnidadeId': unidadeId,
      'Origem': _determinarOrigem(
        latitude: latitude,
        longitude: longitude,
      ),
    };

    if (latitude != null) dto['Latitude'] = latitude;

    if (longitude != null) dto['Longitude'] = longitude;

    // Precisa ser uma parte com Content-Type: application/json. Mandando como
    // campo simples, o @RequestPart do controller devolvia 415 e nada era
    // gravado. É o mesmo que o postarReport faz.
    request.files.add(
      http.MultipartFile.fromString(
        'avistamentoDTO',
        jsonEncode(dto),
        contentType: MediaType('application', 'json'),
      ),
    );

    // Bytes em vez de caminho: na web o XFile não tem path, e o fromPath
    // quebrava justamente lá. O contentType precisa ir junto: sem ele a
    // parte do arquivo não tem Content-Type e o backend recusa a imagem.
    request.files.add(
      http.MultipartFile.fromBytes(
        'imagem',
        await imagem.readAsBytes(),
        filename: imagem.name,
        contentType: mediaTypeDaImagem(imagem.name),
      ),
    );

    final response = await ApiClient.multipart(request);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao enviar avistamento: ${response.statusCode}',
      );
    }
  }

  String _determinarOrigem({
    double? latitude,
    double? longitude,
  }) {
    if (latitude != null && longitude != null) {
      return 'GPS_CELULAR';
    }

    return 'NAO_INFORMADA';
  }
}

