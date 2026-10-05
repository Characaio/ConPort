import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onde as preferências **do aparelho** ficam guardadas entre uma execução e
/// outra.
///
/// Só o que é da tela — tema, tamanho de fonte, estilo do mapa — mora aqui.
/// As preferências de **conta** (perfil público, notificações) vão para o
/// banco, em [PreferenciasConta], porque quem entra em outro celular espera
/// encontrar as mesmas respostas.
///
/// A troca em tempo de execução é o que permite testar sem
/// `SharedPreferences`: `flutter test` não tem o canal de plataforma, então ler
/// de verdade daria `MissingPluginException` no meio de um `setUp`.
abstract class AppSettingsStore {
  /// Guarda usada pelo app. Nos testes isso é trocado por
  /// [AppSettingsStoreMemoria].
  static AppSettingsStore instancia = AppSettingsStorePreferencias();

  /// Tempo máximo de cada operação antes de ser abandonada.
  ///
  /// Preferência que não gravou não é preferência perdida: o app continua com o
  /// valor em memória. Por isso a gravação nunca trava a interface, e a leitura
  /// — que é o primeiro passo da abertura — não pode ficar pendurada.
  static const Duration limite = Duration(seconds: 3);

  Future<Map<String, Object?>> ler();

  Future<void> gravar(String chave, Object valor);

  Future<void> apagar();
}

/// Guarda em `SharedPreferences`.
class AppSettingsStorePreferencias implements AppSettingsStore {
  AppSettingsStorePreferencias({Duration? limite})
    : _limite = limite ?? AppSettingsStore.limite;

  final Duration _limite;

  @override
  Future<Map<String, Object?>> ler() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_limite);

      // `getKeys` + `get` em vez de ler tudo de uma vez: o mapa devolvido pelo
      // pacote tem os valores já convertidos e é só copiar.
      return {
        for (final chave in prefs.getKeys())
          if (chave.startsWith(_prefixo) && chave.length > _prefixo.length)
            chave.substring(_prefixo.length): _valorDe(prefs, chave),
      };
    } catch (e) {
      // Sem plugin, sem permissão, ou o disco demorando: abre com o padrão.
      debugPrint('SETTINGS STORE ERRO ao ler: $e');

      return {};
    }
  }

  @override
  Future<void> gravar(String chave, Object valor) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_limite);

      if (valor is bool) {
        await prefs.setBool(_comPrefixo(chave), valor);
      } else if (valor is double) {
        await prefs.setDouble(_comPrefixo(chave), valor);
      } else if (valor is int) {
        await prefs.setInt(_comPrefixo(chave), valor);
      } else {
        await prefs.setString(_comPrefixo(chave), valor.toString());
      }
    } catch (e) {
      debugPrint('SETTINGS STORE ERRO ao gravar $chave: $e');
    }
  }

  @override
  Future<void> apagar() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_limite);

      for (final chave in prefs.getKeys().where((c) => c.startsWith(_prefixo))) {
        await prefs.remove(chave);
      }
    } catch (e) {
      debugPrint('SETTINGS STORE ERRO ao apagar: $e');
    }
  }

  static Object? _valorDe(SharedPreferences prefs, String chave) =>
      // `get` devolve null tanto para "não existe" quanto para "existe e é
      // nulo"; aqui todo valor gravado é escalar, então não há essa ambiguidade.
      prefs.get(chave);

  static String _comPrefixo(String chave) => '$_prefixo$chave';

  /// Namespace das chaves: evita colidir com o resto do app e com outros
  /// plugins que também escrevem no `SharedPreferences`.
  static const String _prefixo = 'conport.settings.';
}

/// Guarda em memória, para os testes.
class AppSettingsStoreMemoria implements AppSettingsStore {
  final Map<String, Object> _valores = {};

  @override
  Future<Map<String, Object?>> ler() async => Map.of(_valores);

  @override
  Future<void> gravar(String chave, Object valor) async {
    _valores[chave] = valor;
  }

  @override
  Future<void> apagar() async => _valores.clear();
}
