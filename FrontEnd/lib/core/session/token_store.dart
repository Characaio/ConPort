import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Onde o token da sessão fica guardado entre uma execução do app e outra.
///
/// Só o token: o resto do perfil é cache e pode ser recarregado. Guardar
/// no cofre do sistema (Keychain/Keystore) e não em arquivo comum é o que
/// faz o token não virar texto legível por qualquer outro app do aparelho.
abstract class TokenStore {
  /// Guarda usada pelo app. Nos testes isso é trocado por
  /// [TokenStoreMemoria]: `flutter test` não tem Keychain, e uma tentativa de
  /// ler lá daria `MissingPluginException` no meio de um `setUp`.
  static TokenStore instancia = TokenStoreSeguro();

  /// Tempo máximo da **leitura** antes de ela ser abandonada.
  ///
  /// O cofre fala com o sistema (Keychain, Keystore, cofre do navegador) e há
  /// situações em que a resposta simplesmente nunca chega: plugin não
  /// registrado nesta execução, desktop sem serviço de segredos, navegador
  /// bloqueado. Como a leitura do token é o primeiro passo da abertura do app,
  /// uma operação pendurada aqui prenderia o app na tela de carregamento para
  /// sempre — então a leitura tem este limite e, no pior caso, a pessoa entra
  /// de novo.
  ///
  /// Gravar e apagar ficam de fora: são em segundo plano (o app não espera
  /// nenhuma delas para continuar) e um temporizador nelas só jogaria tempo
  /// pendurado para quem estiver testando.
  static const Duration limite = Duration(seconds: 4);

  /// Token guardado, ou `null` se ninguém entrou neste aparelho.
  Future<String?> ler();

  /// Guarda [token] para as próximas execuções.
  Future<void> gravar(String token);

  /// Esquece o token (logout, troca de conta, token recusado pelo servidor).
  Future<void> apagar();
}

/// Guarda o token no cofre do sistema operacional.
class TokenStoreSeguro implements TokenStore {
  TokenStoreSeguro({FlutterSecureStorage? storage, Duration? limite})
    : _storage =
          storage ??
          // Sem opções de plataforma: o padrão do pacote já cifra com
          // AES-GCM e protege a chave no Keystore do Android (e Keychain no
          // iOS/macOS), que é o que queremos.
          const FlutterSecureStorage(),
      _limite = limite ?? TokenStore.limite;

  final FlutterSecureStorage _storage;

  /// Só existe para o teste não esperar os [TokenStore.limite] reais.
  final Duration _limite;

  static const String _chave = 'conport.token.sessao';

  @override
  Future<String?> ler() async {
    try {
      return await _storage.read(key: _chave).timeout(_limite);
    } catch (e) {
      // Cofre indisponível (desktop sem serviço de segredos, web sem permissão,
      // plugin ausente) ou pendurado até estourar [TokenStore.limite]: nenhum
      // desses casos pode derrubar o app — o pior é a pessoa entrar de novo.
      debugPrint('TOKEN STORE ERRO ao ler: $e');

      return null;
    }
  }

  @override
  Future<void> gravar(String token) async {
    try {
      await _storage.write(key: _chave, value: token);
    } catch (e) {
      debugPrint('TOKEN STORE ERRO ao gravar: $e');
    }
  }

  @override
  Future<void> apagar() async {
    try {
      await _storage.delete(key: _chave);
    } catch (e) {
      debugPrint('TOKEN STORE ERRO ao apagar: $e');
    }
  }
}

/// Guarda o token só na memória: some quando o processo acaba.
///
/// Serve para os testes e como reserva quando [TokenStore.instancia] precisa
/// de uma troca temporária.
class TokenStoreMemoria implements TokenStore {
  TokenStoreMemoria([this.token]);

  String? token;

  /// Quantas vezes cada operação foi chamada — o teste usa para conferir que
  /// o token não foi regravado a cada chamada de rede.
  int leituras = 0;
  int gravuras = 0;
  int limpeza = 0;

  @override
  Future<String?> ler() async {
    leituras++;

    return token;
  }

  @override
  Future<void> gravar(String value) async {
    gravuras++;
    token = value;
  }

  @override
  Future<void> apagar() async {
    limpeza++;
    token = null;
  }
}