import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';

class AvistamentoService {
  const AvistamentoService();

  Future<void> enviar(XFile imagem) async {
    if (!AppConfig.usarApi) {
      // Simula a latência da rede enquanto o endpoint não existe.
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    // TODO: ajustar rota e campos quando o backend definir o endpoint.
    // Provavelmente vai precisar de usuarioId, unidadeId e localização também.
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/avistamentos'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagem',
        await imagem.readAsBytes(),
        filename: imagem.name,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao enviar avistamento: ${response.statusCode}');
    }
  }
}
