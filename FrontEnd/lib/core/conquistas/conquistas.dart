import 'package:flutter/material.dart';

import 'package:conport/core/notificacoes/notificacao_controller.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/conquista_mock.dart';
import 'package:conport/models/conquista.dart';
import 'package:conport/services/conquista_service.dart';
import 'package:conport/services/notificacaoService.dart';

// Reexporta o model para as telas só precisarem importar este arquivo.
export 'package:conport/models/conquista.dart';

/// Progresso de conquistas da sessão atual.
///
/// Fica em memória (junto com a sessão); o serviço cuida de persistir no
/// mock ou na API. Ouça com `addListener` para a tela se atualizar quando
/// algo for desbloqueado.
class Conquistas extends ChangeNotifier {
  Conquistas._();

  static final Conquistas instance = Conquistas._();

  final ConquistaService _service = ConquistaService();

  final Set<TipoConquista> _desbloqueadas = {};

  /// Catálogo: título, descrição e ícone de cada conquista.
  List<Conquista> get todas => ConquistaMock.todas;

  int get total => ConquistaMock.todas.length;

  int get quantidadeDesbloqueadas => _desbloqueadas.length;

  Set<TipoConquista> get desbloqueadas => Set.unmodifiable(_desbloqueadas);

  bool estaDesbloqueada(TipoConquista tipo) => _desbloqueadas.contains(tipo);

  Conquista conquista(TipoConquista tipo) =>
      ConquistaMock.todas.firstWhere((c) => c.tipo == tipo);

  /// Visitantes não têm conta: no mock isso não importa (o progresso é
  /// local); com a API, o endpoint precisa de um usuário logado.
  int get _usuarioId => AuthSession.instance.usuario?.id ?? 0;

  /// Carrega o progresso salvo (memória no mock, servidor na API).
  Future<void> carregar() async {
    try {
      final tipos = await _service.buscarDesbloqueadas(_usuarioId);

      _desbloqueadas
        ..clear()
        ..addAll(tipos);

      notifyListeners();
    } catch (e) {
      debugPrint('CONQUISTAS ERROR: $e');
    }
  }

  /// Desbloqueia [tipo].
  ///
  /// Devolve a conquista quando ela é nova e `null` quando já estava
  /// desbloqueada — é assim que a tela sabe se deve avisar.
  Future<Conquista?> desbloquear(TipoConquista tipo) async {
    if (_desbloqueadas.contains(tipo)) return null;

    await _service.desbloquear(_usuarioId, tipo);

    _desbloqueadas.add(tipo);
    notifyListeners();

    return conquista(tipo);
  }

  /// Marca como desbloqueada sem falar com o serviço.
  ///
  /// Para quando a tela já esperou o desbloqueio ter dado certo: aí o erro de
  /// rede vem depois e não pode desfazer o que a pessoa já fez na tela.
  void marcarLocal(TipoConquista tipo) {
    _desbloqueadas.add(tipo);
    notifyListeners();
  }

  /// Volta ao zero (usado nos testes).
  void reiniciar() {
    _desbloqueadas.clear();
    notifyListeners();
  }
}

/// Registra a ação no sistema de conquistas e, se algo novo foi
/// desbloqueado, mostra o aviso na tela e cria a notificação do sino.
///
/// Chame depois da ação dar certo:
/// await registrarConquista(context, TipoConquista.reportEnviado);
Future<void> registrarConquista(
  BuildContext context,
  TipoConquista tipo,
) async {
  Conquista? conquista;

  try {
    conquista = await Conquistas.instance.desbloquear(tipo);
  } catch (e) {
    // A conquista é um extra: se o servidor estiver fora, a ação principal
    // (enviar report, ver vídeo…) já aconteceu e não pode virar erro na tela.
    Conquistas.instance.marcarLocal(tipo);
    debugPrint('CONQUISTA ERROR: $e');
  }

  if (conquista == null || !context.mounted) return;

  // Só o app sabe o título da conquista ("Alerta!"), então é daqui que sai a
  // notificação; as de cadastro e amizade nascem no backend.
  _notificarConquista(conquista);

  final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: appColors.accentGreen,
      content: Row(
        children: [
          Icon(conquista.icone, size: 18, color: appColors.onAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conquista desbloqueada: ${conquista.titulo}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: appColors.onAccent,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Cria a notificação do sino para a conquista liberada e recarrega a lista,
/// para o número do sino já aparecer atualizado sem precisar abrir o popup.
///
/// Só o app sabe o texto da conquista ("Alerta!"), então é daqui que sai esta
/// notificação; as de cadastro e amizade nascem no backend.
Future<void> _notificarConquista(Conquista conquista) async {
  final usuarioId = AuthSession.instance.usuario?.id ?? 0;

  if (usuarioId == 0) return;

  try {
    await NotificacaoService().criar(
      usuarioId,
      titulo: 'Conquista desbloqueada!',
      texto: '${conquista.titulo}: ${conquista.descricao}',
    );

    await NotificacaoController.instance.carregar();
  } catch (e) {
    // Sem notificação a conquista continua valendo; só o sino não avisa, e
    // isso não pode virar erro na tela de quem acabou de enviar um report.
    debugPrint('NOTIFICACAO CONQUISTA ERROR: $e');
  }
}
