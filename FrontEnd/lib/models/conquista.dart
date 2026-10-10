import 'package:flutter/material.dart';

/// As ações que podem render uma conquista.
///
/// [chave] é o nome estável enviado para a API (assim o backend não
/// depende do português dos títulos).
enum TipoConquista {
  reportEnviado('report_enviado'),
  avistamentoEnviado('avistamento_enviado'),
  recompensaResgatada('recompensa_resgatada'),
  videoAssistido('video_assistido'),
  amigoAdicionado('amigo_adicionado'),
  missaoConcluida('missao_concluida');

  final String chave;

  const TipoConquista(this.chave);

  /// Converte o que veio da API; chave desconhecida é ignorada.
  static TipoConquista? porChave(String chave) {
    for (final tipo in TipoConquista.values) {
      if (tipo.chave == chave) return tipo;
    }

    return null;
  }
}

/// Uma conquista do app: o que desbloqueou e como ela aparece na tela.
class Conquista {
  final TipoConquista tipo;
  final String titulo;
  final String descricao;
  final IconData icone;

  const Conquista({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.icone,
  });
}
