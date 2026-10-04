import 'dart:convert';
import 'dart:typed_data';

import 'package:conport/models/usuario.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../mocks/usuario_mock.dart';
import 'package:conport/mocks/amigo_mock.dart';
import 'package:conport/models/amigo.dart';
import 'multipart_media_type.dart';

class UsuarioService {
  const UsuarioService();

  Future<Usuario> pegarDados(int id, {int? visorId}) async {
    if (!AppConfig.usarApi) {
      return UsuarioMock.pegarDados(id);
    }

    // visorId diz de quem é o ponto de vista; sem ele o backend devolve o
    // perfil neutro (tudo falso) e os botões da tela não sabem o que fazer.
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id').replace(
      queryParameters: {if (visorId != null) 'visorId': '$visorId'},
    );

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
    if (!AppConfig.usarApi) {
      return AmigoMock.buscar(termo, ignorar: usuarioId);
    }

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

    // A rota é /amizade e não /seguir: "seguir" agora é follow, que é outra
    // ação e não pede nada.
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/amizade/$alvoId'),
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

  /// Salva os dados editáveis do perfil e devolve o usuário já atualizado.
  ///
  /// Só os campos não nulos vão no corpo: o backend trata o PUT como parcial,
  /// então deixar [senha] fora é o que faz "não mexer na senha".
  Future<Usuario> atualizarPerfil(
    int id, {
    String? nome,
    String? username,
    String? email,
    DateTime? dataNasc,
    String? cidade,
    String? estado,
    String? senha,
    String? senhaAtual,
  }) async {
    if (!AppConfig.usarApi) {
      final atual = UsuarioMock.pegarDados(id);

      return Usuario(
        id: atual.id,
        nome: nome ?? atual.nome,
        username: username ?? atual.username,
        email: email ?? atual.email,
        datanasc: dataNasc ?? atual.datanasc,
        cidade: cidade ?? atual.cidade,
        estado: estado ?? atual.estado,
        senha: senha ?? atual.senha,
        confiavel: atual.confiavel,
        xp: atual.xp,
        level: atual.level,
        moedas: atual.moedas,
        avatar: atual.avatar,
        datacadastro: atual.datacadastro,
        seguidores: atual.seguidores,
        seguindo: atual.seguindo,
        reportsEnviados: atual.reportsEnviados,
        reportsResolvidos: atual.reportsResolvidos,
        reportsRejeitados: atual.reportsRejeitados,
        reportsPendentes: atual.reportsPendentes,
        missoesConcluidas: atual.missoesConcluidas,
      );
    }

    final corpo = <String, dynamic>{};

    if (nome != null) corpo['nome'] = nome;
    if (username != null) corpo['username'] = username;
    if (email != null) corpo['email'] = email;
    if (dataNasc != null) {
      corpo['dataNasc'] = dataNasc.toIso8601String().substring(0, 10);
    }
    if (cidade != null) corpo['cidade'] = cidade;
    if (estado != null) corpo['estado'] = estado;
    if (senha != null) corpo['senha'] = senha;
    if (senhaAtual != null) corpo['senhaAtual'] = senhaAtual;

    final response = await http.put(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(corpo),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw _erroDoBackend(response, 'Não foi possível salvar o perfil.');
  }

  /// Envia a foto do perfil e devolve o nome do arquivo salvo.
  ///
  /// Os bytes vão em vez do caminho porque no Android novo e na web o arquivo
  /// escolhido pelo seletor não tem `path`. O `contentType` precisa ir junto:
  /// sem ele a parte do arquivo não tem Content-Type e o backend recusa.
  Future<String> atualizarAvatar(
    int id, {
    required Uint8List bytes,
    required String nome,
  }) async {
    if (!AppConfig.usarApi) return nome;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/avatar'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: nome,
        contentType: mediaTypeDaImagem(nome),
      ),
    );

    final resposta = await http.Response.fromStream(await request.send());

    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      final json = jsonDecode(resposta.body);

      if (json is Map && json['Avatar'] != null) return '${json['Avatar']}';
    }

    throw _erroDoBackend(resposta, 'Não foi possível enviar a foto.');
  }

  Future<void> removerAvatar(int id) async {
    if (!AppConfig.usarApi) return;

    final response = await http.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/avatar'),
    );

    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw _erroDoBackend(response, 'Não foi possível remover a foto.');
  }

  Future<void> remover(int id, int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.removerAmigo(id, alvoId);
      return;
    }

    final response = await http.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/amizade/$alvoId'),
    );

    if (response.statusCode == 204) return;

    throw Exception('Erro ao remover amigo: ${response.statusCode}');
  }

  // ============================================================
  // SEGUIR
  // ============================================================

  /// Seguir é imediato e não pede nada para o outro lado.
  Future<void> seguir(int id, int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.seguir(id, alvoId);
      return;
    }

    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/seguindo/$alvoId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw _erroDoBackend(response, 'Não foi possível seguir.');
  }

  Future<void> deixarDeSeguir(int id, int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.deixarDeSeguir(id, alvoId);
      return;
    }

    final response = await http.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/seguindo/$alvoId'),
    );

    if (response.statusCode == 204) return;

    throw _erroDoBackend(response, 'Não foi possível deixar de seguir.');
  }

  /// Quem [usuarioId] segue.
  ///
  /// Levanta [ListaPrivada] quando a visibilidade da pessoa não deixa o
  /// visor abrir a lista — é assim que a tela sabe mostrar "privada" em vez
  /// de "ninguém segue".
  Future<List<Amigo>> listarSeguindo(int usuarioId, {int? visorId}) async {
    if (!AppConfig.usarApi) {
      _checarPrivacidadeMock(usuarioId, visorId);
      return AmigoMock.seguindo(usuarioId);
    }

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$usuarioId/seguindo').replace(
        queryParameters: {if (visorId != null) 'visorId': '$visorId'},
      ),
    );

    if (response.statusCode == 200) return _amigosDe(response.body);

    if (response.statusCode == 403) throw ListaPrivada(_motivoDe(response));

    throw _erroDoBackend(response, 'Não foi possível carregar a lista.');
  }

  Future<List<Amigo>> listarSeguidores(int usuarioId, {int? visorId}) async {
    if (!AppConfig.usarApi) {
      _checarPrivacidadeMock(usuarioId, visorId);
      return AmigoMock.seguidores(usuarioId);
    }

    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$usuarioId/seguidores').replace(
        queryParameters: {if (visorId != null) 'visorId': '$visorId'},
      ),
    );

    if (response.statusCode == 200) return _amigosDe(response.body);

    if (response.statusCode == 403) throw ListaPrivada(_motivoDe(response));

    throw _erroDoBackend(response, 'Não foi possível carregar a lista.');
  }

  /// Quem pode ver as listas de [id]. Salva no banco: a escolha sobrevive
  /// ao fechar o app.
  Future<VisibilidadeSeguidores> atualizarVisibilidade(
    int id,
    VisibilidadeSeguidores visibilidade,
  ) async {
    if (!AppConfig.usarApi) {
      UsuarioMock.definirVisibilidade(id, visibilidade);
      return visibilidade;
    }

    final response = await http.put(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$id/privacidade'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'visibilidade': visibilidade.nome}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return VisibilidadeSeguidores.porNome(
        json is Map ? json['Visibilidade'] : null,
      );
    }

    throw _erroDoBackend(response, 'Não foi possível salvar a preferência.');
  }

  List<Amigo> _amigosDe(String body) {    final lista = jsonDecode(body) as List;

    return lista.map((e) => Amigo.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _motivoDe(http.Response response) {
    final corpo = response.body.trim();

    return corpo.isNotEmpty && corpo.length <= 200
        ? corpo.replaceAll('"', '')
        : 'Esta lista é privada.';
  }
}

/// A lista existe, mas a visibilidade da pessoa não deixa você abrir.
class ListaPrivada implements Exception {
  final String motivo;

  const ListaPrivada([this.motivo = 'Esta lista é privada.']);

  @override
  String toString() => motivo;
}

/// Mesma regra do backend para o modo demonstração, onde a visibilidade é
/// local: sem isso a tela deixaria abrir uma lista que na API seria barrada.
void _checarPrivacidadeMock(int usuarioId, int? visorId) {
  final visibilidade = UsuarioMock.visibilidade(usuarioId);

  if (visibilidade == VisibilidadeSeguidores.publico) return;
  if (visorId != null && visorId == usuarioId) return;

  if (visibilidade == VisibilidadeSeguidores.privado) {
    throw const ListaPrivada('Esta lista é privada.');
  }

  if (visorId == null || !AmigoMock.saoAmigos(visorId, usuarioId)) {
    throw const ListaPrivada('Esta lista só é visível para amigos.');
  }
}

/// Converte a resposta de erro do backend numa exceção legível.
///
/// O backend manda a mensagem do problema direto no corpo ("Username já em
/// uso", "Senha atual incorreta"), mas às vezes vem outra coisa — como o
/// stack trace do [GlobalExceptionHandler] num 404. nesses casos o genérico é
/// melhor do que um trace na tela.
Exception _erroDoBackend(http.Response response, String padrao) {
  var corpo = response.body.trim();

  if (corpo.startsWith('[') || corpo.startsWith('{')) corpo = '';

  if (corpo.isNotEmpty && corpo.length <= 200) {
    return Exception(corpo.replaceAll('"', '').trim());
  }

  return Exception('$padrao (${response.statusCode})');
}
