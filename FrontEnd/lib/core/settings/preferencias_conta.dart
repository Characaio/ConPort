import 'package:flutter/foundation.dart';

import 'package:conport/models/preferencias.dart';
import 'package:conport/services/usuarioService.dart';

/// As preferências que pertencem à **conta**, não ao aparelho.
///
/// Diferente de [AppSettings]: quem entra no celular da tia espera encontrar
/// o mesmo "perfil privado" de quando saiu daqui. Por isso estas vão para o
/// banco, e não para o `SharedPreferences`.
///
/// O estado em memória serve para a tela abrir com o último valor conhecido
/// (sem esperar a rede) e é reescrito por [carregar] quando o servidor
/// responde.
class PreferenciasConta extends ChangeNotifier {
  PreferenciasConta._();

  static final PreferenciasConta instance = PreferenciasConta._();

  final UsuarioService _service = const UsuarioService();

  Preferencias? _atual;
  bool _carregando = false;
  bool _salvando = false;
  String? _erro;

  /// Estado atual, ou `null` enquanto nunca foi lido.
  ///
  /// A tela esconde os interruptores enquanto for `null`: mostrar o padrão e
  /// depois trocar na frente da pessoa seria pior que esperar.
  Preferencias? get atual => _atual;

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;

  /// Busca as preferências da conta.
  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _atual = await _service.pegarPreferencias();
      _erro = null;
    } catch (e) {
      debugPrint('PREFERENCIAS ERRO ao carregar: $e');
      _erro = 'Não foi possível carregar suas preferências.';
    }

    _carregando = false;
    notifyListeners();
  }

  /// Liga ou desliga uma preferência e confirma com o servidor.
  ///
  /// A mudança aparece na hora e volta se o servidor recusar: o botão fica
  /// onde a pessoa colocou. O contrário — travar o botão esperando a resposta —
  /// faz a tela parecer quebrada em internet ruim, que é justamente quando a
  /// pessoa mais precisa do que está marcado.
  Future<void> definir(PreferenciasChave chave, bool valor) async {
    final anterior = _atual;

    // Sem estado ainda não há o que inverter, e sem `_atual` o botão nem
    // deveria estar visível.
    if (anterior == null || _salvando) return;

    if (anterior.valorDe(chave) == valor) return;

    _atual = anterior.com(chave, valor);
    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      _atual = await _service.atualizarPreferencias({chave: valor});
      _erro = null;
    } catch (e) {
      debugPrint('PREFERENCIAS ERRO ao salvar: $e');
      _atual = anterior;
      _erro = 'Não foi possível salvar essa preferência.';
    }

    _salvando = false;
    notifyListeners();
  }

  /// Esquce as preferências carregadas (logout, troca de conta).
  ///
  /// Sem isso, quem entra depois veria os interruptores da conta que saiu.
  void limpar() {
    _atual = null;
    _carregando = false;
    _salvando = false;
    _erro = null;
    notifyListeners();
  }
}
