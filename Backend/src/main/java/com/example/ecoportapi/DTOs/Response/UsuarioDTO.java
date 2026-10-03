package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Usuario;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record UsuarioDTO(
    Long Id,
    String Nome,
    String Username,
    LocalDate DataNasc,
    String Email,
    String Estado,
    String Cidade,
    String Avatar,
    LocalDateTime DataCadastro,
    boolean Confiavel,
    Integer XP,
    Integer Level,
    Integer Moedas,
    long Seguidores,
    long Seguindo) {
  public UsuarioDTO(Usuario usuario, long seguidores, long seguindo) {
    this(
        usuario.getId(),
        usuario.getNome(),
        usuario.getUsername(),
        usuario.getDataNasc(),
        usuario.getEmail(),
        usuario.getEstado(),
        usuario.getCidade(),
        usuario.getAvatar(),
        usuario.getDataCadastro(),
        usuario.isConfiavel(),
        usuario.getXP(),
        usuario.getLevel(),
        usuario.getMoedas(),
        seguidores,
        seguindo);
  }
}
