package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Usuario;

public record UsuarioResumoDTO(
    Long Id,
    String Nome,
    String Apelido,
    String Avatar,
    Integer Level,
    Integer XP,
    Long RelacaoId) {

  /// Para listas onde a linha da relação não importa (ex.: busca).
  public UsuarioResumoDTO(Usuario usuario) {
    this(usuario, null);
  }

  /// Para listas de amigos e solicitações, o id da relação é necessário
  /// para aceitar e recusar.
  public UsuarioResumoDTO(Usuario usuario, Long relacaoId) {
    this(
        usuario.getId(),
        usuario.getNome(),
        usuario.getApelido(),
        usuario.getAvatar(),
        usuario.getLevel(),
        usuario.getXP(),
        relacaoId);
  }
}