package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Perfil de um usuário, com o ponto de vista de quem está vendo.
 *
 * <p>Os três booleanos do fim dependem de quem abriu a tela, então só valem
 * quando o {@code visorId} foi informado (via {@code ?visorId=}). Sem sessão,
 * quem lê recebe o perfil neutro.
 */
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
    long Seguindo,
    String Visibilidade,
    boolean Amigo,
    boolean EuSigo,
    boolean SegueMe) {

  public UsuarioDTO(Usuario usuario) {
    this(usuario, 0, 0, false, false, false);
  }

  public UsuarioDTO(
      Usuario usuario,
      long seguidores,
      long seguindo,
      boolean amigo,
      boolean euSigo,
      boolean segueMe) {
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
        seguindo,
        visibilidade(usuario),
        amigo,
        euSigo,
        segueMe);
  }

  /// Nulo no banco é tratado como público: é o que toda conta já tinha.
  private static String visibilidade(Usuario usuario) {
    VisibilidadeSeguidores v = usuario.getVisibilidade();
    return (v == null ? VisibilidadeSeguidores.PUBLICO : v).name();
  }
}
