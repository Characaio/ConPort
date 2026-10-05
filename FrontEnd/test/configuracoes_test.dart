import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/core/settings/app_settings_store.dart';
import 'package:conport/models/preferencias.dart';

/// Configurações do aparelho e preferências de conta.
///
/// O [AppSettings] é singleton, então cada teste começa restaurando o padrão
/// contra a guarda em memória: sem isso o tema deixado por um teste vaza para
/// o seguinte e a falha aponta para o lugar errado.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettingsStoreMemoria guarda;

  setUp(() async {
    guarda = AppSettingsStoreMemoria();
    AppSettingsStore.instancia = guarda;

    await AppSettings.instance.restaurarPadroes();
  });

  tearDown(() {
    AppSettingsStore.instancia = AppSettingsStorePreferencias();
  });

  group('AppSettings guarda no aparelho', () {
    test('a preferência volta depois de "reabrir o app"', () async {
      AppSettings.instance
        ..setThemeMode(ThemeMode.dark)
        ..setHighContrast(true)
        ..setReduceMotion(true)
        ..setEstiloMapa(EstiloMapa.escuro)
        ..setUnidadeDistancia(UnidadeDistancia.metros);

      // Simula a reabertura: a instância já carregou do disco antes; aqui
      // recarrega para confirmar que o que foi gravado volta depois.
      await AppSettings.instance.carregar();

      expect(AppSettings.instance.themeMode, ThemeMode.dark);
      expect(AppSettings.instance.highContrast, isTrue);
      expect(AppSettings.instance.reduceMotion, isTrue);
      expect(AppSettings.instance.estiloMapa, EstiloMapa.escuro);
      expect(AppSettings.instance.unidadeDistancia, UnidadeDistancia.metros);
    });

    test('o que não foi salvo volta no padrão, não numa mistura', () async {
      AppSettings.instance.setThemeMode(ThemeMode.dark);
      await AppSettings.instance.restaurarPadroes();

      expect(AppSettings.instance.themeMode, ThemeMode.light);
    });

    test('restaurar padrões limpa também o que já estava gravado', () async {
      AppSettings.instance
        ..setThemeMode(ThemeMode.dark)
        ..setSeguirTemaSistema(true)
        ..setNotificarPush(true)
        ..setFontScale(AppSettings.tamanhosFonte.last.$2);
      await AppSettings.instance.restaurarPadroes();

      expect(await guarda.ler(), isEmpty);
    });

    test('o valor gravado é o nome do enum, não a posição dele', () async {
      // Se amanhã entrar um tema novo no meio da lista, "dark" guardado tem de
      // continuar sendo dark e não virar o tema que estiver na posição 2.
      AppSettings.instance.setThemeMode(ThemeMode.dark);

      final salvos = await guarda.ler();

      expect(salvos['themeMode'], 'dark');
    });

    test('escala de fora do limite é puxada para dentro dele', () async {
      AppSettings.instance.setFontScale(9.0);

      expect(AppSettings.instance.fontScale, 1.3);

      AppSettings.instance.setFontScale(0.1);

      expect(AppSettings.instance.fontScale, 0.85);
    });

    test('seguroTemaSistema persiste e muda o themeMode retornado', () async {
      AppSettings.instance.setThemeMode(ThemeMode.dark);
      AppSettings.instance.setSeguirTemaSistema(true);

      expect(AppSettings.instance.themeMode, ThemeMode.system);
      expect(AppSettings.instance.seguirTemaSistema, isTrue);
      expect((await guarda.ler())['seguirTemaSistema'], isTrue);

      AppSettings.instance.setSeguirTemaSistema(false);

      expect(AppSettings.instance.themeMode, ThemeMode.dark);
      expect(AppSettings.instance.seguirTemaSistema, isFalse);
    });

    test('ultimoTemaManual sobrevive ao carregar', () async {
      AppSettings.instance.setThemeMode(ThemeMode.dark);
      await AppSettings.instance.carregar();

      expect(AppSettings.instance.ultimoTemaManual, ThemeMode.dark);
    });

    test('notificarPush persiste', () async {
      AppSettings.instance.setNotificarPush(true);
      await AppSettings.instance.carregar();

      expect(AppSettings.instance.notificarPush, isTrue);
    });

    test('grava com a chave do app, para não colidir com outro plugin', () async {
      AppSettings.instance.setHighContrast(true);

      expect(await guarda.ler(), {'highContrast': true});
    });
  });

  group('Reduzir animações', () {
    test('com a opção ligada, a duração vira zero', () {
      AppSettings.instance.setReduceMotion(true);

      expect(
        AppSettings.instance.duracao(const Duration(milliseconds: 350)),
        Duration.zero,
      );
    });

    test('com a opção desligada, a duração passa direto', () {
      AppSettings.instance.setReduceMotion(false);

      expect(
        AppSettings.instance.duracao(const Duration(milliseconds: 350)),
        const Duration(milliseconds: 350),
      );
    });
  });

  group('Unidade de distância', () {
    test('quilômetros arredonda para uma casa, metros para inteiro', () {
      expect(UnidadeDistancia.quilometros.formatar(1549), '1.5 km');
      expect(UnidadeDistancia.metros.formatar(1549), '1549 m');
    });

    test('o app formata pela unidade escolhida', () {
      AppSettings.instance.setUnidadeDistancia(UnidadeDistancia.metros);

      expect(AppSettings.instance.formatarDistancia(800), '800 m');

      AppSettings.instance.setUnidadeDistancia(UnidadeDistancia.quilometros);

      expect(AppSettings.instance.formatarDistancia(800), '0.8 km');
    });

    test('nome desconhecido não quebra a leitura do que foi salvo', () {
      expect(UnidadeDistancia.doNome('milhas'), UnidadeDistancia.quilometros);
    });
  });

  group('Tamanhos de fonte predefinidos', () {
    test('lista cobre todo o intervalo do slider', () {
      expect(AppSettings.tamanhosFonte.first.$2, 0.85);
      expect(AppSettings.tamanhosFonte.last.$2, 1.3);
      expect(AppSettings.tamanhosFonte.length, greaterThanOrEqualTo(4));
    });

    test('o preset Normal é 1.0', () {
      final normal = AppSettings.tamanhosFonte.firstWhere(
          (p) => p.$1 == 'Normal');

      expect(normal.$2, 1.0);
    });
  });

  group('Estilo do mapa', () {
    test('chave desconhecida volta para o padrão em vez de sumir', () {
      expect(EstiloMapa.daChave('hiperspace'), EstiloMapa.claro);
    });

    test('cada estilo aponta para um endereço de estilo', () {
      for (final estilo in EstiloMapa.values) {
        expect(estilo.styleUri, startsWith('https://'));
      }
    });
  });

  group('Preferências de conta', () {
    test('campo ausente vira o padrão do servidor', () {
      final prefs = Preferencias.fromJson({'perfilPublico': false});

      expect(prefs.perfilPublico, isFalse);
      expect(prefs.permiteSolicitacoes, isTrue);
      expect(prefs.notificarNoApp, isTrue);
      expect(prefs.notificarEmail, isFalse);
      expect(prefs.compartilharLocalizacao, isFalse);
      expect(prefs.dadosDeUsoAnonimo, isTrue);
    });

    test('"com" muda só o campo pedido', () {
      final antes = Preferencias.padroes();
      final depois = antes.com(PreferenciasChave.notificarNoApp, false);

      expect(depois.notificarNoApp, isFalse);
      expect(depois.perfilPublico, antes.perfilPublico);
      expect(depois.dadosDeUsoAnonimo, antes.dadosDeUsoAnonimo);
    });

    test('o corpo parcial leva só o que mudou', () {
      final corpo = Preferencias.padroes().toJsonParcial({
        PreferenciasChave.perfilPublico: false,
      });

      // Uma chave só: o backend trata o que não vem como "deixa como está".
      expect(corpo, {'perfilPublico': false});
    });

    test('a chave da tela e a chave do servidor não podem divergir', () {
      for (final chave in PreferenciasChave.values) {
        expect(PreferenciasChave.daChave(chave.chaveNoServidor), chave);
      }
    });
  });
}
