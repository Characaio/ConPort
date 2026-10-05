import 'package:flutter/foundation.dart';

/// Quais preferencias existem, e o nome que cada uma tem no servidor.
///
/// O enum existe para o resto do app não passar a chave do banco de um lado e o
/// texto da tela do outro: [chaveNoServidor] é o único lugar que conhece o
/// contrato com o backend.
enum PreferenciasChave {
  perfilPublico('perfilPublico', 'Perfil público'),
  permiteSolicitacoes('permiteSolicitacoes', 'Permitir solicitações de amizade'),
  notificarNoApp('notificarNoApp', 'Notificações no aplicativo'),
  notificarEmail('notificarEmail', 'Notificações por e-mail'),
  compartilharLocalizacao('compartilharLocalizacao', 'Compartilhar localização'),
  dadosDeUsoAnonimo('dadosDeUsoAnonimo', 'Dados de uso anônimos');

  const PreferenciasChave(this.chaveNoServidor, this.rotulo);

  final String chaveNoServidor;
  final String rotulo;

  static PreferenciasChave daChave(String chave) => values.firstWhere(
    (p) => p.chaveNoServidor == chave,
    orElse: () => PreferenciasChave.dadosDeUsoAnonimo,
  );
}

/// As seis preferências de conta, já com o que veio do servidor.
///
/// Os campos são `bool` e não `bool?` porque o backend resolve o nulo para o
/// padrão antes de responder (e uma coluna nova nunca deve virar um interruptor
/// que aparece desligado sem ninguém ter escolhido isso).
@immutable
class Preferencias {
  final bool perfilPublico;
  final bool permiteSolicitacoes;
  final bool notificarNoApp;
  final bool notificarEmail;
  final bool compartilharLocalizacao;
  final bool dadosDeUsoAnonimo;

  const Preferencias({
    required this.perfilPublico,
    required this.permiteSolicitacoes,
    required this.notificarNoApp,
    required this.notificarEmail,
    required this.compartilharLocalizacao,
    required this.dadosDeUsoAnonimo,
  });

  /// O mesmo que o backend assume para conta sem preferência salva.
  factory Preferencias.padroes() => const Preferencias(
    perfilPublico: true,
    permiteSolicitacoes: true,
    notificarNoApp: true,
    notificarEmail: false,
    compartilharLocalizacao: false,
    dadosDeUsoAnonimo: true,
  );

  factory Preferencias.fromJson(Map<String, dynamic> json) {
    final padroes = Preferencias.padroes();

    return Preferencias(
      perfilPublico: _bool(json['perfilPublico'], padroes.perfilPublico),
      permiteSolicitacoes: _bool(
        json['permiteSolicitacoes'],
        padroes.permiteSolicitacoes,
      ),
      notificarNoApp: _bool(json['notificarNoApp'], padroes.notificarNoApp),
      notificarEmail: _bool(json['notificarEmail'], padroes.notificarEmail),
      compartilharLocalizacao: _bool(
        json['compartilharLocalizacao'],
        padroes.compartilharLocalizacao,
      ),
      dadosDeUsoAnonimo: _bool(
        json['dadosDeUsoAnonimo'],
        padroes.dadosDeUsoAnonimo,
      ),
    );
  }

  bool valorDe(PreferenciasChave chave) => switch (chave) {
    PreferenciasChave.perfilPublico => perfilPublico,
    PreferenciasChave.permiteSolicitacoes => permiteSolicitacoes,
    PreferenciasChave.notificarNoApp => notificarNoApp,
    PreferenciasChave.notificarEmail => notificarEmail,
    PreferenciasChave.compartilharLocalizacao => compartilharLocalizacao,
    PreferenciasChave.dadosDeUsoAnonimo => dadosDeUsoAnonimo,
  };

  Preferencias com(PreferenciasChave chave, bool valor) => Preferencias(
    perfilPublico: _troca(perfilPublico, chave, PreferenciasChave.perfilPublico, valor),
    permiteSolicitacoes: _troca(
      permiteSolicitacoes,
      chave,
      PreferenciasChave.permiteSolicitacoes,
      valor,
    ),
    notificarNoApp: _troca(notificarNoApp, chave, PreferenciasChave.notificarNoApp, valor),
    notificarEmail: _troca(notificarEmail, chave, PreferenciasChave.notificarEmail, valor),
    compartilharLocalizacao: _troca(
      compartilharLocalizacao,
      chave,
      PreferenciasChave.compartilharLocalizacao,
      valor,
    ),
    dadosDeUsoAnonimo: _troca(
      dadosDeUsoAnonimo,
      chave,
      PreferenciasChave.dadosDeUsoAnonimo,
      valor,
    ),
  );

  /// Corpo do `PUT` com só [chaves] — o backend trata campo ausente como
  /// "deixa como está", que é o que permite enviar um botão por vez.
  Map<String, dynamic> toJsonParcial(Map<PreferenciasChave, bool> chaves) => {
    for (final entrada in chaves.entries)
      entrada.key.chaveNoServidor: entrada.value,
  };

  static bool _troca(
    bool atual,
    PreferenciasChave mudando,
    PreferenciasChave alvo,
    bool valor,
  ) => mudando == alvo ? valor : atual;

  /// Ausente ou nulo vira o padrão: é o que a coluna nova no banco parece para
  /// quem já tinha conta.
  static bool _bool(Object? bruto, bool padrao) => bruto is bool ? bruto : padrao;
}
