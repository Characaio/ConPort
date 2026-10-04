package com.example.ecoportapi.Models.Enums;

/**
 * Quem pode abrir as listas de "quem sigo" e "quem me segue".
 *
 * <p>O nome é o mesmo nas duas listas de propósito: no app elas andam
 * juntas, como as chaves de Configurações que ajustam.
 */
public enum VisibilidadeSeguidores {
  /** Qualquer pessoa com a URL vê a lista. */
  PUBLICO,

  /** Só o próprio e os amigos aprovados. */
  SO_AMIGOS,

  /** Só o próprio. */
  PRIVADO
}
