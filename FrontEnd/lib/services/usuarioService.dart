import 'dart:convert';

import 'package:conport/models/usuario.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../mocks/usuario_mock.dart';
import 'package:conport/mocks/amigo_mock.dart';
import 'package:conport/models/amigo.dart';

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

  Future<List<Amigo>> listarAmigos(int id) async {
    if (!AppConfig.usarApi) return AmigoMock.amigos();

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/amigos'),
    );

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar amigos: ${response.statusCode}');
  }

  Future<List<Amigo>> listarSolicitacoes(int id) async {
    if (!AppConfig.usarApi) return AmigoMock.solicitacoes();

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/solicitacoes'),
    );

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar solicitações: ${response.statusCode}');
  }

  Future<List<Amigo>> buscar(String termo, {int? usuarioId}) async {
    if (!AppConfig.usarApi) return AmigoMock.amigos();

    // O id vai junto para o backend não devolver a própria conta.
    final uri = Uri.parse('${AppConfig.apiUrl}/usuarios/buscar').replace(
      queryParameters: {
        'termo': termo,
        if (usuarioId != null) 'usuarioId': '$usuarioId',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar usuários: ${response.statusCode}');
  }

  Future<void> enviarSolicitacao(int id, int alvoId) async {
    if (!AppConfig.usarApi) return;

    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/seguir/$alvoId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;
    if (response.statusCode == 409) {
      throw Exception(response.body);
    }

    throw Exception('Erro ao enviar solicitação: ${response.statusCode}');
  }

  Future<void> aceitar(int id, int relacaoId) async {
    if (!AppConfig.usarApi) return;

    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/aceitar/$relacaoId'),
    );

    if (response.statusCode == 200) return;

    throw Exception('Erro ao aceitar: ${response.statusCode}');
  }

  Future<void> recusar(int id, int relacaoId) async {
    if (!AppConfig.usarApi) return;

    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/recusar/$relacaoId'),
    );

    if (response.statusCode == 200) return;

    throw Exception('Erro ao recusar: ${response.statusCode}');
  }

  Future<void> remover(int id, int alvoId) async {
    if (!AppConfig.usarApi) return;

    final response = await http.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/seguir/$alvoId'),
    );

    if (response.statusCode == 204) return;

    throw Exception('Erro ao remover amigo: ${response.statusCode}');
  }
}
