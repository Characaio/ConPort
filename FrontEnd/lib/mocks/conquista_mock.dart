import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/models/conquista.dart';

/// Definições das conquistas e o progresso guardado em memória enquanto
/// `AppConfig.usarApi` for `false`.
///
/// Com a API ligada, a lista de baixo continua sendo o catálogo (títulos e
/// ícones) e o progresso passa a morar no servidor.
class ConquistaMock {
  ConquistaMock._();

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

  static final Set<TipoConquista> _desbloqueadas = {};

  static List<TipoConquista> desbloqueadas() => _desbloqueadas.toList();

  /// `true` quando a conquista estava bloqueada e passou a valer agora.
  static bool desbloquear(TipoConquista tipo) => _desbloqueadas.add(tipo);

  /// Volta o progresso ao início (usado nos testes).
  static void reiniciar() => _desbloqueadas.clear();
}
