import 'package:flutter/material.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/settings/preferencias_conta.dart';
import 'package:conport/models/notificacao.dart';
import 'package:conport/services/notificacaoService.dart';

// Reexporta o model para as telas só precisarem importar este arquivo.
export 'package:conport/models/notificacao.dart';

/// Notificações da sessão atual.
///
/// Fica em memória (junto com a sessão); o [NotificacaoService] cuida de
/// persistir no mock ou na API. Ouça com `addListener` para a tela se
/// atualizar depois de marcar algo como lida.
///
/// O estado "lida" mora no backend para o sino continuar certo depois que o
/// app fecha — mas enquanto a tela está aberta é esta lista quem manda, por
/// isso [marcarComoLida] já deixa o item atualizado antes de a rede responder.
class NotificacaoController extends ChangeNotifier {
  NotificacaoController._();

  static final NotificacaoController instance = NotificacaoController._();

  final NotificacaoService _service = NotificacaoService();

  List<Notificacao> _notificacoes = [];
  bool _carregando = false;
  String? _erro;

  /// Todas, da mais recente para a mais antiga (o que o popup mostra).
  List<Notificacao> get notificacoes => List.unmodifiable(_notificacoes);

  /// Quantas ainda não foram lidas — o número do sino.
  int get naoLidas =>
      _notificacoes.where((n) => n.naoLida).length;

  bool get temNaoLidas => naoLidas > 0;

  /// `true` enquanto a lista está sendo buscada (para o spinner).
  bool get carregando => _carregando;

  /// Mensagem da última falha, ou `null` se deu certo.
  ///
  /// A lista antiga continua na tela nesse caso: em vez de sumir com tudo,
  /// o melhor é avisar e manter o que já era conhecido.
  String? get erro => _erro;

  /// A pessoa desligou as notificações no aplicativo.
  bool get desligadas {
    final prefs = PreferenciasConta.instance.atual;

    return prefs != null && !prefs.notificarNoApp;
  }

  /// Visitantes não têm conta: com a API, `/usuarios/0/...` seria 404.
  int get _usuarioId => AuthSession.instance.usuario?.id ?? 0;

  /// Busca as notificações do usuário.
  ///
  /// Chame ao abrir o popup e ao voltar para a tela inicial — é o que
  /// atualiza o sino depois que outra parte do app criou algo.
  Future<void> carregar() async {
    // Sem usuário logado não há o que listar, e não vale a pena gastar uma
    // chamada que volta 404.
    if (_usuarioId == 0) {
      _notificacoes = [];
      _erro = null;
      notifyListeners();
      return;
    }

    _carregando = true;
    _erro = null;
    notifyListeners();

    // "Notificações no aplicativo" desligado: a lista volta vazia, então o sino
    // não mostra nada — nem contador, nem popup. As notificações continuam
    // guardadas no servidor e voltam se a opção for religada.
    //
    // Só vale quando as preferências já chegaram (`null` = ainda não
    // carregadas): esconder o sino por um instante a cada abertura seria pior
    // do que mostrar.
    if (desligadas) {
      _notificacoes = [];
      _erro = null;
      _carregando = false;
      notifyListeners();

      return;
    }

    try {
      _notificacoes = await _service.listar(_usuarioId);
    } catch (e) {
      _erro = 'Não foi possível carregar as notificações.';
      debugPrint('NOTIFICACOES ERROR: $e');
    }

    _carregando = false;
    notifyListeners();
  }

  /// Marca uma notificação como lida.
  ///
  /// Atualiza a lista na hora (a bolinha vermelha some imediatamente) e só
  /// depois confirma com o servidor; se a rede falhar, volta ao estado
  /// anterior em vez de deixar a tela mostrando algo que não foi salvo.
  Future<void> marcarComoLida(int notificacaoId) async {
    final indice = _indiceDe(notificacaoId);

    // Já estava lida: nada a fazer (e o backend também trataria como no-op).
    if (indice == -1 || _notificacoes[indice].lida) return;

    final anterior = _notificacoes[indice];
    _notificacoes[indice] = anterior.copyWith(lida: true);
    notifyListeners();

    try {
      final atualizada = await _service.marcarComoLida(_usuarioId, notificacaoId);

      // Usa a versão do servidor: se o `data`/`texto` mudaram lá, a tela
      // passa a mostrar o que é verdade.
      _notificacoes[indice] = atualizada;
    } catch (e) {
      _notificacoes[indice] = anterior;
      _erro = 'Não foi possível marcar a notificação como lida.';
      debugPrint('NOTIFICACOES ERROR: $e');
    }

    notifyListeners();
  }

  /// Marca todas como lidas.
  Future<void> marcarTodasComoLidas() async {
    if (naoLidas == 0) return;

    // Mesma ideia do [marcarComoLida]: otimista na tela, reverte se falhar.
    final anteriores = List<Notificacao>.from(_notificacoes);

    _notificacoes = _notificacoes
        .map((n) => n.copyWith(lida: true))
        .toList();
    notifyListeners();

    try {
      await _service.marcarTodasComoLidas(_usuarioId);
      _erro = null;
    } catch (e) {
      _notificacoes = anteriores;
      _erro = 'Não foi possível marcar todas como lidas.';
      debugPrint('NOTIFICACOES ERROR: $e');
    }

    notifyListeners();
  }

  /// Exclui uma notificação.
  Future<void> excluir(int notificacaoId) async {
    final indice = _indiceDe(notificacaoId);

    if (indice == -1) return;

    final removida = _notificacoes.removeAt(indice);
    notifyListeners();

    try {
      await _service.excluir(_usuarioId, notificacaoId);
      _erro = null;
    } catch (e) {
      // Devolve no lugar em que estava, e não no fim da lista.
      _notificacoes.insert(indice, removida);
      _erro = 'Não foi possível excluir a notificação.';
      debugPrint('NOTIFICACOES ERROR: $e');
    }

    notifyListeners();
  }

  /// Esquece a lista (logout / troca de conta).
  ///
  /// Sem isso a notificação da conta anterior continuaria na tela de quem
  /// entrou depois.
  void limpar() {
    _notificacoes = [];
    _erro = null;
    _carregando = false;
    notifyListeners();
  }

  int _indiceDe(int notificacaoId) =>
      _notificacoes.indexWhere((n) => n.id == notificacaoId);
}
