package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Usuario;

/**
 * As preferências de conta, do jeito que o menu de configurações mostra.
 *
 * <p>Separado do {@link UsuarioDTO} de propósito: o perfil é o que os outros
 * veem, e isto é o que só a própria pessoa vê e muda. Misturar os dois faria a
 * tela de perfil de terceiro carregar (e expor) as preferências dela.
 *
 * <p>Todos os campos saem resolvidos: nunca chegam {@code null} daqui, porque
 * os getters do {@link Usuario} já aplicam o padrão.
 */
public record PreferenciasDTO(
    boolean perfilPublico,
    boolean permiteSolicitacoes,
    boolean notificarNoApp,
    boolean notificarEmail,
    boolean compartilharLocalizacao,
    boolean dadosDeUsoAnonimo) {

  public PreferenciasDTO(Usuario usuario) {
    this(
        usuario.isPerfilPublico(),
        usuario.isPermiteSolicitacoes(),
        usuario.isNotificarNoApp(),
        usuario.isNotificarEmail(),
        usuario.isCompartilharLocalizacao(),
        usuario.isDadosDeUsoAnonimo());
  }
}
