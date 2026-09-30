import 'dart:convert';

import 'package:conport/models/usuario.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../mocks/usuario_mock.dart';

class UsuarioService {
  const UsuarioService();

  Future<Usuario> pegarDados(int id) async {
    if (!AppConfig.usarApi) {
      return UsuarioMock.pegarDados(id);
    }

    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Usuario.fromJson(json);
    }

    if (response.statusCode == 404) {
      throw Exception('Usuario não encontrado');
    }

    throw Exception('Erro ao buscar Usuario: ${response.statusCode}');
  }
}
