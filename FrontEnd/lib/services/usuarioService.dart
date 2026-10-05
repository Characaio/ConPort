import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:conport/models/amigo.dart';
import 'package:conport/models/conquista.dart';
import 'package:conport/models/mission.dart';
import 'package:conport/models/notificacao.dart';
import 'package:conport/models/preferencias.dart';
import 'package:conport/models/report_lista.dart';
import 'package:conport/models/usuario.dart';

import '../config/app_config.dart';
import '../core/session/api_client.dart';
import '../core/session/auth_session.dart';
import '../mocks/conquista_mock.dart';
import '../mocks/usuario_mock.dart';
import 'conquista_service.dart';
import 'missaoService.dart';
import 'notificacaoService.dart';
import 'reportService.dart';
import 'package:conport/mocks/amigo_mock.dart';
import 'package:conport/models/amigo.dart';
import 'multipart_media_type.dart';

/// Perfil,_amizade, seguir e privacidade.
///
/// Depois da sessão por token, a separação é a mesma do backend: o que é de
/// quem está olhando (`pegarDados`, `buscar`, listas) continua público e manda o
/// token só para o servidor saber de quem é o ponto de vista; o que é seu
/// (amigos, solicitações, perfil, avatar, privacidade) vai para `/usuarios/eu`
/// e o usuário nem aparece na rota — trocar o id na URL não troca mais de
/// conta.
class UsuarioService {
  const UsuarioService();

  /// Quem está logado agora; `0` quando não há ninguém.
  ///
  /// Só o modo mock precisa do id para endereçar o mock: lá o progresso é
  /// local e precisa saber de quem é. Com a API, quem é a conta vem do token.
  int get _idDaSessao => AuthSession.instance.usuario?.id ?? 0;

  Future<Usuario> pegarDados(int id, {int? visorId}) async {
    if (!AppConfig.usarApi) {
      return UsuarioMock.pegarDados(id);
    }

    // Quem está vendo vem do token. O [visorId] fica só para o modo mock, em
    // que não existe servidor para olhar o token: sem ele, o mock não sabe
    // dizer se você já segue essa pessoa.
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id');

    final response = await ApiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Usuario.fromJson(json);
    }

    if (response.statusCode == 404) {
      throw Exception('Usuario não encontrado');
    }

    throw Exception('Erro ao buscar Usuario: ${response.statusCode}');
  }

  /// O perfil de quem está logado, vindo do token.
  Future<Usuario> minhaConta() async {
    if (!AppConfig.usarApi) {
      return UsuarioMock.pegarDados(_idDaSessao);
    }

    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu'),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Não foi possível carregar a sua conta.');
  }

  Future<List<Amigo>> listarAmigos() async {
    if (!AppConfig.usarApi) return AmigoMock.amigos();

    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/amigos'),
    );

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar amigos: ${response.statusCode}');
  }

  Future<List<Amigo>> listarSolicitacoes() async {
    if (!AppConfig.usarApi) return AmigoMock.solicitacoes();

    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/solicitacoes'),
    );

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar solicitações: ${response.statusCode}');
  }

  Future<List<Amigo>> buscar(String termo) async {
    if (!AppConfig.usarApi) {
      return AmigoMock.buscar(termo, ignorar: _idDaSessao);
    }

    // Público: quem não tem conta precisa achar alguém para seguir. O token
    // é que faz o backend não devolver a própria conta no resultado.
    final uri = Uri.parse(
      '${AppConfig.apiUrl}/usuarios/buscar',
    ).replace(queryParameters: {'termo': termo});

    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return lista
          .map((e) => Amigo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao buscar usuários: ${response.statusCode}');
  }

  Future<void> enviarSolicitacao(int alvoId) async {
    if (!AppConfig.usarApi) return;

    // A rota é /amizade e não /seguir: "seguir" agora é follow, que é outra
    // ação e não pede nada.
    final response = await ApiClient.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/amizade/$alvoId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;
    if (response.statusCode == 409) {
      throw Exception(response.body);
    }

    throw Exception('Erro ao enviar solicitação: ${response.statusCode}');
  }

  Future<void> aceitar(int relacaoId) async {
    if (!AppConfig.usarApi) return;

    final response = await ApiClient.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/aceitar/$relacaoId'),
    );

    if (response.statusCode == 200) return;

    throw Exception('Erro ao aceitar: ${response.statusCode}');
  }

  Future<void> recusar(int relacaoId) async {
    if (!AppConfig.usarApi) return;

    final response = await ApiClient.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/recusar/$relacaoId'),
    );

    if (response.statusCode == 200) return;

    throw Exception('Erro ao recusar: ${response.statusCode}');
  }

  /// Salva os dados editáveis do perfil e devolve o usuário já atualizado.
  ///
  /// Só os campos não nulos vão no corpo: o backend trata o PUT como parcial,
  /// então deixar [senha] fora é o que faz "não mexer na senha".
  Future<Usuario> atualizarPerfil({
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
      final atual = UsuarioMock.pegarDados(_idDaSessao);

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
        visibilidade: atual.visibilidade,
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

    final response = await ApiClient.putJson(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu'),
      corpo,
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
  Future<String> atualizarAvatar({
    required Uint8List bytes,
    required String nome,
  }) async {
    if (!AppConfig.usarApi) return nome;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/avatar'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: nome,
        contentType: mediaTypeDaImagem(nome),
      ),
    );

    final resposta = await ApiClient.multipart(request);

    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      final json = jsonDecode(resposta.body);

      if (json is Map && json['Avatar'] != null) return '${json['Avatar']}';
    }

    throw _erroDoBackend(resposta, 'Não foi possível enviar a foto.');
  }

  Future<void> removerAvatar() async {
    if (!AppConfig.usarApi) return;

    final response = await ApiClient.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/avatar'),
    );

    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw _erroDoBackend(response, 'Não foi possível remover a foto.');
  }

  Future<void> removerAmigo(int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.removerAmigo(_idDaSessao, alvoId);
      return;
    }

    final response = await ApiClient.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/amizade/$alvoId'),
    );

    if (response.statusCode == 204) return;

    throw Exception('Erro ao remover amigo: ${response.statusCode}');
  }

  // ============================================================
  // SEGUIR
  // ============================================================

  /// Seguir é imediato e não pede nada para o outro lado.
  Future<void> seguir(int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.seguir(_idDaSessao, alvoId);
      return;
    }

    final response = await ApiClient.post(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/seguir/$alvoId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw _erroDoBackend(response, 'Não foi possível seguir.');
  }

  Future<void> deixarDeSeguir(int alvoId) async {
    if (!AppConfig.usarApi) {
      AmigoMock.deixarDeSeguir(_idDaSessao, alvoId);
      return;
    }

    final response = await ApiClient.delete(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/seguir/$alvoId'),
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

    // No servidor quem está vendo vem do token; o [visorId] só serve ao mock.
    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$usuarioId/seguindo'),
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

    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/$usuarioId/seguidores'),
    );

    if (response.statusCode == 200) return _amigosDe(response.body);

    if (response.statusCode == 403) throw ListaPrivada(_motivoDe(response));

    throw _erroDoBackend(response, 'Não foi possível carregar a lista.');
  }

  /// Quem pode ver as listas de quem está logado. Salva no banco: a escolha
  /// sobrevive ao fechar o app.
  Future<VisibilidadeSeguidores> atualizarVisibilidade(
    VisibilidadeSeguidores visibilidade,
  ) async {
    if (!AppConfig.usarApi) {
      UsuarioMock.definirVisibilidade(_idDaSessao, visibilidade);
      return visibilidade;
    }

    final response = await ApiClient.putJson(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/privacidade'),
      {'visibilidade': visibilidade.nome},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return VisibilidadeSeguidores.porNome(
        json is Map ? json['Visibilidade'] : null,
      );
    }

    throw _erroDoBackend(response, 'Não foi possível salvar a preferência.');
  }

  List<Amigo> _amigosDe(String body) {
    final lista = jsonDecode(body) as List;

    return lista.map((e) => Amigo.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _motivoDe(http.Response response) {
    final corpo = response.body.trim();

    return corpo.isNotEmpty && corpo.length <= 200
        ? corpo.replaceAll('"', '')
        : 'Esta lista é privada.';
  }

  // ============================================================
  // PREFERÊNCIAS DE CONTA
  // ============================================================

  /// As preferências da conta logada, já com os padrões do servidor aplicados.
  Future<Preferencias> pegarPreferencias() async {
    if (!AppConfig.usarApi) {
      return UsuarioMock.preferencias(_idDaSessao);
    }

    final response = await ApiClient.get(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/preferencias'),
    );

    if (response.statusCode == 200) {
      return Preferencias.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _erroDoBackend(
      response,
      'Não foi possível carregar suas preferências.',
    );
  }

  /// Manda só [mudancas] e devolve o estado completo que o servidor gravou.
  Future<Preferencias> atualizarPreferencias(
    Map<PreferenciasChave, bool> mudancas,
  ) async {
    if (mudancas.isEmpty) return pegarPreferencias();

    if (!AppConfig.usarApi) {
      return UsuarioMock.definirPreferencias(_idDaSessao, mudancas);
    }

    final corpo = Preferencias.padroes().toJsonParcial(mudancas);

    final response = await ApiClient.putJson(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu/preferencias'),
      corpo,
    );

    if (response.statusCode == 200) {
      return Preferencias.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _erroDoBackend(response, 'Não foi possível salvar essa preferência.');
  }

  // ============================================================
  // EXCLUIR CONTA
  // ============================================================

  /// Apaga a conta depois de confirmar a senha.
  ///
  /// A senha vai no corpo e não na URL: query string de senha acaba em log de
  /// proxy. O backend responde 401 quando ela não bate, e o app só sai da conta
  /// depois do 200 — assim uma senha errada não deixa a pessoa deslogada sem
  /// conta nenhuma.
  Future<void> excluirConta(String senha) async {
    if (!AppConfig.usarApi) {
      // No mock não há banco para apagar; confirmar e seguir é o que dá para
      // fazer sem fingir que o servidor respondeu.
      return;
    }

    final response = await ApiClient.deleteJson(
      Uri.parse('${AppConfig.apiUrl}/usuarios/eu'),
      {'senha': senha},
    );

    if (response.statusCode == 200) return;

    throw _erroDoBackend(response, 'Não foi possível excluir a conta.');
  }

  // ============================================================
  // EXPORTAR DADOS
  // ============================================================

  /// Um retrato de tudo que o backend guarda sobre a conta logada.
  ///
  /// Vai montado aqui (e não na tela) para que o formato do arquivo seja
  /// testável e não dependa de widget nenhum.
  Future<Map<String, dynamic>> exportarDados() async {
    final conta = await minhaConta();

    final dados = <String, dynamic>{
      'exportado_em': DateTime.now().toIso8601String(),
      'conta': {
        'id': conta.id,
        'nome': conta.nome,
        'username': conta.username,
        'email': conta.email,
        'cidade': conta.cidade,
        'estado': conta.estado,
        'data_de_nascimento': conta.datanasc.toIso8601String(),
        'data_de_cadastro': conta.datacadastro?.toIso8601String(),
        'xp': conta.xp,
        'level': conta.level,
        'moedas': conta.moedas,
        'confiavel': conta.confiavel,
      },
    };

    // Cada bloco é independente: uma seção que falha não pode impedir o resto
    // de sair. Um retrato parcial ainda é útil; um retrato que não saiu, não.
    dados['amigos'] = await _exportar<Amigo>(
      listarAmigos,
      (a) => {
        'id': a.id,
        'nome': a.nome,
        'username': a.username,
        'nivel': a.nivel,
      },
    );

    dados['missoes'] = await _exportar<Mission>(
      () => MissaoService().listarMissoes(),
      (m) => {
        'id': m.id,
        'titulo': m.title,
        'status': m.status.name,
        'progresso': m.progress,
        'meta': m.goal,
      },
    );

    dados['reports'] = await _exportar<ReportLista>(
      () => ReportService().buscarMeusReports(),
      (r) => {
        'id': r.id,
        'tipo': r.tipo.name,
        'status': r.status.name,
        'descricao': r.descricao,
        'unidade': r.unidadeNome,
        'latitude': r.latitude,
        'longitude': r.longitude,
        'data': r.dataDoOcorrido.toIso8601String(),
      },
    );

    dados['conquistas'] = await _exportar<TipoConquista>(
      () => ConquistaService().buscarDesbloqueadas(
        _idDaSessao,
        daSessao: true,
      ),
      // O serviço devolve só a chave de cada conquista; o título e a descrição
      // vivem no catálogo local, e é dele que saem para o arquivo.
      (c) {
        final meta = ConquistaMock.todas
            .where((d) => d.tipo == c)
            .firstOrNull;

        return {
          'chave': c.chave,
          'titulo': meta?.titulo,
          'descricao': meta?.descricao,
        };
      },
    );

    dados['notificacoes'] = await _exportar<Notificacao>(
      () => NotificacaoService().listar(_idDaSessao),
      (n) => {
        'titulo': n.titulo,
        'texto': n.texto,
        'data': n.data.toIso8601String(),
        'lida': n.lida,
      },
    );

    // As seis preferências entram pelo mesmo caminho das outras seções: uma
    // falha aqui também vira lista vazia em vez de derrubar o arquivo.
    final prefs = await _exportarPreferencias();
    dados['preferencias'] = prefs;

    return dados;
  }

  Future<Map<String, dynamic>> _exportarPreferencias() async {
    try {
      final prefs = await pegarPreferencias();

      return prefs.toJsonParcial({
        for (final chave in PreferenciasChave.values)
          chave: prefs.valorDe(chave),
      });
    } catch (e) {
      return {};
    }
  }

  /// Roda [buscar] e converte em JSON, devolvendo lista vazia se falhar.
  Future<List<Map<String, dynamic>>> _exportar<T>(
    Future<List<T>> Function() buscar,
    Map<String, dynamic> Function(T) converter,
  ) async {
    try {
      return (await buscar()).map(converter).toList();
    } catch (e) {
      // Falha de rede aqui não pode impedir o arquivo de sair: o resto do
      // retrato ainda é o que a pessoa pediu.
      return [];
    }
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