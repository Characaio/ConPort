import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/core/session/auth_session.dart';

/// As chamadas HTTP do app, com o token da sessão embutido.
///
/// Existe por dois motivos:
///
/// 1. **O header.** Nenhum serviço monta `Authorization` na mão: um serviço
///    que esquecer isso só descobre o problema quando o backend responde 401
///    em produção, e no modo mock (que é o padrão) o header nem existe.
/// 2. **A vigia de 401.** Token revogado ou expirado não pode virar erro
///    críptico espalhado por doze telas: quando uma chamada autenticada volta
///    401, a sessão é derrubada aqui e o app volta para a tela de acesso.
class ApiClient {
  ApiClient._();

  /// Cliente usado nas chamadas.
  ///
  /// `null` é o normal: cada chamada abre e fecha o próprio cliente, como o
  /// `package:http` faz. Nos testes isso é substituído por um `MockClient`,
  /// para dar para conferir o header enviado e simular o 401 sem subir nada.
  static http.Client? cliente;

  /// Cabeçalhos de uma chamada.
  ///
  /// [json] acrescenta o `Content-Type` de JSON — quem envia `MultipartRequest`
  /// não usa, porque ali quem define o Content-Type é o próprio `http`
  /// (com o boundary do multipart).
  ///
  /// [token] sobrescreve o da sessão: é o que a sondagem de inicialização usa
  /// para provar um token guardado antes de ele virar a sessão.
  static Map<String, String> cabecalhos({
    bool json = false,
    String? token,
  }) {
    final headers = <String, String>{};

    if (json) headers['Content-Type'] = 'application/json';

    final usado = token ?? AuthSession.instance.token;

    if (usado != null && usado.isNotEmpty) {
      headers['Authorization'] = 'Bearer $usado';
    }

    return headers;
  }

  static Future<http.Response> get(Uri url, {String? token}) =>
      _enviar('GET', url, headers: cabecalhos(token: token));

  static Future<http.Response> post(Uri url, {String? token}) =>
      _enviar('POST', url, headers: cabecalhos(token: token));

  static Future<http.Response> postJson(
    Uri url,
    Object corpo, {
    String? token,
  }) => _enviar(
    'POST',
    url,
    headers: cabecalhos(json: true, token: token),
    body: jsonEncode(corpo),
  );

  static Future<http.Response> putJson(
    Uri url,
    Object corpo, {
    String? token,
  }) => _enviar(
    'PUT',
    url,
    headers: cabecalhos(json: true, token: token),
    body: jsonEncode(corpo),
  );

  static Future<http.Response> patch(Uri url, {String? token}) =>
      _enviar('PATCH', url, headers: cabecalhos(token: token));

  static Future<http.Response> delete(Uri url, {String? token}) =>
      _enviar('DELETE', url, headers: cabecalhos(token: token));

  /// Envia um [http.MultipartRequest] já montado.
  ///
  /// O multipart recebe só o header de autorização: quem põe o Content-Type
  /// (com o boundary) é o `http`, e mandar `application/json` aqui quebraria
  /// o envio.
  static Future<http.Response> multipart(
    http.MultipartRequest request, {
    String? token,
  }) {
    final headers = cabecalhos(token: token);

    return _vigia(headers, () async {
      request.headers.addAll(headers);

      return http.Response.fromStream(await request.send());
    });
  }

  /// Monta e envia um pedido simples, com a vigia de 401 por cima.
  static Future<http.Response> _enviar(
    String metodo,
    Uri url, {
    Map<String, String> headers = const {},
    String? body,
  }) => _vigia(headers, () async {
    // Cliente injetado (só nos testes): o pedido vai montado para o dublê
    // poder conferir método, headers e corpo.
    final proprio = cliente;

    if (proprio != null) {
      final pedido = http.Request(metodo, url)..headers.addAll(headers);

      if (body != null) pedido.body = body;

      return http.Response.fromStream(await proprio.send(pedido));
    }

    // Na rede de verdade a chamada sai pelas funções do próprio pacote, que
    // abrem e fecham o cliente sozinhas. Fazer isso à mão (pedido + fromStream)
    // abre a conexão de um jeito que o Dart só normalmente fecha depois da
    // leitura do corpo: a resposta chega truncada e vira "Connection closed
    // while receiving data".
    return switch (metodo) {
      'POST' => http.post(url, headers: headers, body: body),
      'PUT' => http.put(url, headers: headers, body: body),
      'GET' => http.get(url, headers: headers),
      'PATCH' => http.patch(url, headers: headers),
      _ => http.delete(url, headers: headers),
    };
  });

  /// 401 numa chamada que foi autenticada significa token morto.
  ///
  /// Sem header de autorização não mexe na sessão: aí o 401 é só "e-mail ou
  /// senha incorretos" no login, e a pessoa vai tentar de novo.
  static Future<http.Response> _vigia(
    Map<String, String> headers,
    Future<http.Response> Function() chamada,
  ) async {
    final response = await chamada();

    if (response.statusCode == 401 && headers['Authorization'] != null) {
      AuthSession.instance.tokenRecusado();
    }

    return response;
  }
}