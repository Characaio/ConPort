import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/models/conquista.dart';

/// Definições das conquistas e o progresso guardado em memória enquanto
/// `AppConfig.usarApi` for `false`.
///
/// Com a API ligada, a lista de baixo continua sendo o catálogo (títulos e
/// ícones) e o progresso passa a morar no servidor.
class ConquistaMock {
  ConquistaMock._();

  /// Usuário que representa "eu" nos testes e no modo demonstração.
  static const int usuarioDaSessao = 2;

  static const List<Conquista> todas = [
    Conquista(
      tipo: TipoConquista.reportEnviado,
      titulo: 'Alerta!',
      descricao: 'Envie um report.',
      icone: Symbols.warning,
    ),
    Conquista(
      tipo: TipoConquista.avistamentoEnviado,
      titulo: 'O que é, o que é?',
      descricao: 'Envie um avistamento.',
      icone: Symbols.remove_red_eye,
    ),
    Conquista(
      tipo: TipoConquista.recompensaResgatada,
      titulo: 'Os 5 Rs',
      descricao: 'Resgate uma recompensa.',
      icone: Symbols.redeem,
    ),
    Conquista(
      tipo: TipoConquista.videoAssistido,
      titulo: 'Prática leva a perfeição',
      descricao: 'Assista a um vídeo educativo.',
      icone: Symbols.play_circle,
    ),
    Conquista(
      tipo: TipoConquista.amigoAdicionado,
      titulo: 'Conport? Mais pra Conamigo! Haha.',
      descricao: 'Adicione um amigo.',
      icone: Symbols.person_add,
    ),
  ];

  /// Progresso por usuário. Sem isso todo mundo veria a mesma coisa, e o
  /// perfil de outra pessoa mostraria as conquistas de quem está logado.
  ///
  /// O usuário da sessão começa vazio de propósito: o progresso dele nasce
  /// das ações do app, não de um fixture.
  static final Map<int, Set<TipoConquista>> _porUsuario = {
    usuarioDaSessao: {},
    101: {TipoConquista.avistamentoEnviado, TipoConquista.videoAssistido},
    102: {TipoConquista.reportEnviado},
    103: {
      TipoConquista.reportEnviado,
      TipoConquista.recompensaResgatada,
      TipoConquista.avistamentoEnviado,
    },
  };

  static List<TipoConquista> desbloqueadas([int usuarioId = usuarioDaSessao]) =>
      (_porUsuario[usuarioId] ?? {}).toList();

  /// `true` quando a conquista estava bloqueada e passou a valer agora.
  static bool desbloquear(
    TipoConquista tipo, [
    int usuarioId = usuarioDaSessao,
  ]) => (_porUsuario[usuarioId] ??= {}).add(tipo);

  /// Volta o progresso ao início (usado nos testes).
  static void reiniciar() {
    _porUsuario
      ..clear()
      ..addAll({
        usuarioDaSessao: {},
        101: {TipoConquista.avistamentoEnviado, TipoConquista.videoAssistido},
        102: {TipoConquista.reportEnviado},
        103: {
          TipoConquista.reportEnviado,
          TipoConquista.recompensaResgatada,
          TipoConquista.avistamentoEnviado,
        },
      });
  }
}
