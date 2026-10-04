import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';

class AvistamentoService {
  const AvistamentoService();

  Future<void> enviar({
    required XFile imagem,
    required int unidadeId,
    required int usuarioId,
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

    final campos = <String, String>{
      'UnidadeId': unidadeId.toString(),
      'Origem': _determinarOrigem(
        latitude: latitude,
        longitude: longitude,
      ),
    };

    if (latitude != null) {
      campos['Latitude'] = latitude.toString();
    }

    if (longitude != null) {
      campos['Longitude'] = longitude.toString();
    }

    request.fields['avistamentoDTO'] = _montarJsonDto(campos);

    request.fields['usuarioId'] = usuarioId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'imagem',
        imagem.path,
        filename: imagem.name,
      ),
    );

    final response = await request.send();

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

  String _montarJsonDto(Map<String, String> campos) {
    final partes = <String>[];

    campos.forEach((chave, valor) {
      partes.add('"$chave":${_valorJson(valor)}');
    });

    return '{${partes.join(',')}}';
  }

  String _valorJson(String valor) {
    if (valor == 'GPS_CELULAR' ||
        valor == 'IMAGEM_EXIF' ||
        valor == 'MAPA_MANUAL' ||
        valor == 'NAO_INFORMADA') {
      return '"$valor"';
    }

    if (double.tryParse(valor) != null ||
        int.tryParse(valor) != null) {
      return valor;
    }

    return '"${valor.replaceAll('"', '\\"')}"';
  }
}