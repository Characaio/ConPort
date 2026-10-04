import 'package:conport/models/notificacao.dart';

/// Notificações de mentira enquanto `AppConfig.usarApi` for `false`.
///
/// O texto e o título vêm do mesmo lugar de antes (o mock embutido no popup),
/// só que agora fora do widget, como os outros mocks do app.
///
/// A lista é montada uma vez e guardada em memória, para que marcar como lida
/// e excluir continuem valendo entre uma consulta e outra — é o que o
/// ConquistaMock faz com o progresso.
///
/// Com a API ligada esta lista não é usada: o backend cria a notificação e o
/// app só lê.
class NotificacaoMock {
  NotificacaoMock._();

  static const String _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Nunc commodo turpis leo, ut fringilla lorem posuere a.';

  /// null = ainda não foi pedido para nenhum usuário.
  static List<Notificacao>? _notificacoes;

  static List<Notificacao> _garantir(int usuarioId) {
    final agora = DateTime.now();

    return _notificacoes ??= [
      for (int i = 1; i <= 6; i++)
        Notificacao(
          id: i,
          usuarioId: usuarioId,
          titulo: 'Notificação',
          texto: _lorem,
          data: agora.subtract(Duration(hours: i * 5)),
          // só a primeira começa não lida
          lida: i != 1,
        ),
    ];
  }

  static List<Notificacao> listar(int usuarioId) =>
      List.unmodifiable(_garantir(usuarioId));

  static List<Notificacao> listarNaoLidas(int usuarioId) => _garantir(
    usuarioId,
  ).where((n) => n.naoLida).toList();

  static int contarNaoLidas(int usuarioId) => listarNaoLidas(usuarioId).length;

  static Notificacao marcarComoLida(int usuarioId, int id) {
    _notificacoes = _garantir(usuarioId)
        .map((n) => n.id == id ? n.copyWith(lida: true) : n)
        .toList();

    return _garantir(usuarioId).firstWhere((n) => n.id == id);
  }

  static void marcarTodasComoLidas(int usuarioId) {
    _notificacoes = _garantir(usuarioId)
        .map((n) => n.copyWith(lida: true))
        .toList();
  }

  static void excluir(int usuarioId, int id) {
    _notificacoes = _garantir(usuarioId)
        .where((n) => n.id != id)
        .toList();
  }

  /// Cria uma notificação em memória.
  ///
  /// Com a API ligada quem cria é o backend (cadastro, amizade) ou o próprio
  /// app (conquista); aqui a lista é local e precisava do mesmo caminho para
  /// o sino do modo de demonstração não ficar sempre vazio.
  static Notificacao criar(int usuarioId, String titulo, String texto) {
    final lista = _garantir(usuarioId);
    final id = lista.isEmpty
        ? 1
        : lista.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;

    final nova = Notificacao(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo,
      texto: texto,
      data: DateTime.now(),
    );

    _notificacoes = [nova, ...lista];

    return nova;
  }

  /// Volta ao estado inicial (usado nos testes).
  static void reiniciar() => _notificacoes = null;
}
