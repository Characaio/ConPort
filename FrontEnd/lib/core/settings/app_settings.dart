import 'package:flutter/material.dart';

import 'package:conport/core/settings/app_settings_store.dart';

/// Como distâncias aparecem na tela.
///
/// Distância da unidade só muda a unidade em que o número é escrito — o cálculo
/// continua em metros, que é o que o mapa devolve.
enum UnidadeDistancia {
  quilometros('km', 'Quilômetros', 'Distâncias longas, como entre cidades.'),
  metros('m', 'Metros', 'Precisão para o que está acontecendo perto de você.');

  const UnidadeDistancia(this.simbolo, this.rotulo, this.descricao);

  final String simbolo;
  final String rotulo;
  final String descricao;

  /// Converte metros para a unidade escolhida, já arredondando para uma casa
  /// em km (onde a segunda casa vira ruído) e para inteiro em metros.
  String formatar(double metros) {
    if (this == UnidadeDistancia.metros) return '${metros.round()} m';

    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  static UnidadeDistancia doNome(String? nome) => values.firstWhere(
    (u) => u.name == nome,
    orElse: () => UnidadeDistancia.quilometros,
  );
}

/// Base do mapa.
enum EstiloMapa {
  claro(
    'claro',
    'Claro',
    'Cores suaves, boa de dia.',
    'https://tiles.openfreemap.org/styles/positron',
  ),
  escuro(
    'escuro',
    'Escuro',
    'Combina com o tema escuro do app.',
    'https://tiles.openfreemap.org/styles/dark',
  );

  const EstiloMapa(this.chave, this.rotulo, this.descricao, this.styleUri);

  /// Identificador gravado no aparelho. É o `name` do enum justamente para a
  /// leitura continuar funcionando se alguém inserir um estilo no meio da
  /// lista — o valor antigo não deve virar lixo.
  final String chave;
  final String rotulo;
  final String descricao;

  /// Estilo do OpenFreeMap consumido pelo `flutter_map_vector_tiles`.
  final String styleUri;

  static EstiloMapa daChave(String? chave) => values.firstWhere(
    (e) => e.chave == chave,
    orElse: () => EstiloMapa.claro,
  );
}

/// As configurações que pertencem a **esta tela**, não à conta.
///
/// Tudo aqui é do aparelho: o tema e o tamanho da fonte são do aparelho que
/// está aberto, e é estranho (e-syncronizaria mal) levar "fonte a 130%" para o
/// celular da TV. Já o que a pessoa espera encontrar igual em qualquer
/// aparelho — perfil público, notificações — fica no banco, em
/// `PreferenciasConta`.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  // ============================================================
  // VALORES
  // ============================================================

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode _ultimoTemaManual = ThemeMode.light;
  bool _seguirTemaSistema = false;
  bool _useMaterial3 = true;
  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _notificarPush = false;
  UnidadeDistancia _unidadeDistancia = UnidadeDistancia.quilometros;
  EstiloMapa _estiloMapa = EstiloMapa.claro;

  /// Quando [seguirTemaSistema] é verdadeiro, [themeMode] devolve
  /// [ThemeMode.system]; caso contrário, devolve o tema escolhido manualmente.
  /// Lê [ultimoTemaManual] — o que estava selecionado antes de ligar a opção.
  ThemeMode get themeMode =>
      _seguirTemaSistema ? ThemeMode.system : _themeMode;
  ThemeMode get ultimoTemaManual => _ultimoTemaManual;
  bool get seguirTemaSistema => _seguirTemaSistema;
  bool get useMaterial3 => _useMaterial3;
  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  bool get notificarPush => _notificarPush;
  UnidadeDistancia get unidadeDistancia => _unidadeDistancia;
  EstiloMapa get estiloMapa => _estiloMapa;

  /// Tamanhos de fonte predefinidos, além do slider contínuo.
  ///
  /// Cada par é (rótulo, escala). "Normal" é 1.0, e os demais se espalham
  /// entre o mínimo (0.85) e o máximo (1.3) do slider.
  static final List<(String, double)> tamanhosFonte = [
    ('Pequeno', 0.85),
    ('Normal', 1.0),
    ('Grande', 1.15),
    ('Muito grande', 1.3),
  ];

  /// Escreve uma distância em metros já na unidade escolhida.
  String formatarDistancia(double metros) => _unidadeDistancia.formatar(metros);

  // ============================================================
  // CARREGAR E GRAVAR
  // ============================================================

  /// Lê o que ficou da execução anterior.
  ///
  /// Precisa ser awaited antes do primeiro `runApp`, senão o app abre no tema
  // padrão e pisca para o tema escolhido — pior num aparelho com tema claro
  /// quando a pessoa pediu o escuro.
  ///
  /// Não lança: um `SharedPreferences` indisponível abre o app com os padrões,
  /// que é um resultado aceitável. O pior caso seria a tela de abertura ficar
  // presa esperando este método.
  Future<void> carregar() async {
    Map<String, Object?> salvos;

    try {
      salvos = await AppSettingsStore.instancia.ler();
    } catch (e) {
      debugPrint('SETTINGS: não foi possível carregar: $e');

      return;
    }

    _seguirTemaSistema = _booleanoDe(salvos['seguirTemaSistema']) ?? _seguirTemaSistema;
    _ultimoTemaManual = _temaDe(salvos['ultimoTemaManual']) ?? _ultimoTemaManual;
    _themeMode = _temaDe(salvos['themeMode']) ?? _themeMode;
    _useMaterial3 = _booleanoDe(salvos['useMaterial3']) ?? _useMaterial3;
    _fontScale = _escalaDe(salvos['fontScale']) ?? _fontScale;
    _highContrast = _booleanoDe(salvos['highContrast']) ?? _highContrast;
    _reduceMotion = _booleanoDe(salvos['reduceMotion']) ?? _reduceMotion;
    _notificarPush = _booleanoDe(salvos['notificarPush']) ?? _notificarPush;
    _unidadeDistancia = UnidadeDistancia.doNome(
      salvos['unidadeDistancia'] as String?,
    );
    _estiloMapa = EstiloMapa.daChave(salvos['estiloMapa'] as String?);

    // Não avisa quem chama: quem espera é a abertura, e um `notifyListeners`
    // aqui só faria o app inteiro se redesenhar antes de existir widget nenhum.
  }

  /// Volta tudo ao padrão, gravando o resultado.
  Future<void> restaurarPadroes() async {
    await AppSettingsStore.instancia.apagar();

    _themeMode = ThemeMode.light;
    _ultimoTemaManual = ThemeMode.light;
    _seguirTemaSistema = false;
    _useMaterial3 = true;
    _fontScale = 1.0;
    _highContrast = false;
    _reduceMotion = false;
    _notificarPush = false;
    _unidadeDistancia = UnidadeDistancia.quilometros;
    _estiloMapa = EstiloMapa.claro;

    notifyListeners();
  }

  /// Grava uma chave. Cada `setX` chama isto, então não há caminho em que o
  /// valor muda na tela mas não é salvo.
  ///
  /// Sem `await`: quem mexe no botão não pode esperar o disco. O store engole
  /// o erro, então o `catch` aqui só é para o log.
  void _gravar(String chave, Object valor) {
    AppSettingsStore.instancia
        .gravar(chave, valor)
        .catchError((Object e) => debugPrint('SETTINGS ERRO ao gravar $chave: $e'));
  }

  // ============================================================
  // ANIMAÇÕES
  // ============================================================

  /// Duração a usar num `Animated*` respeitando "Reduzir animações".
  ///
  /// `Duration.zero` não é um truque para a animação sumir: o Flutter ainda
  /// roda a curva, só que instantânea, e o widget chega no mesmo estado final.
  /// É isso que mantém a tela correta com a animação desligada, em vez de
  /// deixar o valor no meio do caminho.
  Duration duracao(Duration normal) => _reduceMotion ? Duration.zero : normal;

  /// Verdadeiro quando dá para animar sem travar quem pediu menos movimento.
  bool get anima => !_reduceMotion;

  // ============================================================
  // SETTERS
  // ============================================================

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    _ultimoTemaManual = value;
    _gravar('themeMode', value.name);
    _gravar('ultimoTemaManual', value.name);
    notifyListeners();
  }

  void setUseMaterial3(bool value) {
    if (_useMaterial3 == value) return;
    _useMaterial3 = value;
    _gravar('useMaterial3', value);
    notifyListeners();
  }

  void setFontScale(double value) {
    final next = value.clamp(0.85, 1.3).toDouble();
    if (_fontScale == next) return;
    _fontScale = next;
    _gravar('fontScale', next);
    notifyListeners();
  }

  /// Quando [value] é verdadeiro o app segue o tema do sistema; ao desligar,
  /// volta para o último tema escolhido manualmente.
  void setSeguirTemaSistema(bool value) {
    if (_seguirTemaSistema == value) return;
    _seguirTemaSistema = value;
    _gravar('seguirTemaSistema', value);

    if (!value) {
      // Restaura o tema manualmente escolhido antes de ligar a opção.
      _themeMode = _ultimoTemaManual;
      _gravar('themeMode', _ultimoTemaManual.name);
    }

    notifyListeners();
  }

  void setNotificarPush(bool value) {
    if (_notificarPush == value) return;
    _notificarPush = value;
    _gravar('notificarPush', value);
    notifyListeners();
  }

  void setHighContrast(bool value) {
    if (_highContrast == value) return;
    _highContrast = value;
    _gravar('highContrast', value);
    notifyListeners();
  }

  void setReduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    _gravar('reduceMotion', value);
    notifyListeners();
  }

  void setUnidadeDistancia(UnidadeDistancia value) {
    if (_unidadeDistancia == value) return;
    _unidadeDistancia = value;
    _gravar('unidadeDistancia', value.name);
    notifyListeners();
  }

  void setEstiloMapa(EstiloMapa value) {
    if (_estiloMapa == value) return;
    _estiloMapa = value;
    _gravar('estiloMapa', value.chave);
    notifyListeners();
  }

  // ============================================================
  // LEITURA
  // ============================================================

  /// Nome gravado é o do enum, e não o índice: se amanhã entrar um tema novo no
  /// meio, quem já tinha "dark" guardado continua sendo "dark" em vez de virar
  /// outro tema por causa de uma posição que mudou.
  static ThemeMode? _temaDe(Object? bruto) {
    if (bruto is! String) return null;

    return ThemeMode.values.where((m) => m.name == bruto).firstOrNull;
  }

  static bool? _booleanoDe(Object? bruto) => bruto is bool ? bruto : null;

  /// Reaplica o limite: um valor antigo gravado com limite maior (ou editado
  /// fora do app) não pode deixar o texto ilegível.
  static double? _escalaDe(Object? bruto) {
    if (bruto is! num) return null;

    return bruto.toDouble().clamp(0.85, 1.3).toDouble();
  }
}
