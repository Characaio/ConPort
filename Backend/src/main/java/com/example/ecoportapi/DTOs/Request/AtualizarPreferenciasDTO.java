package com.example.ecoportapi.DTOs.Request;

/**
 * Atualização parcial das preferências de conta: campo que não vem (nulo) fica
 * como está, o que deixa o app mandar só o botão que a pessoa mexeu.
 *
 * <p>Os campos são {@link Boolean} e não {@code boolean} por causa disso: num
 * record com primitivo, "não veio" e "veio false" seriam a mesma coisa, e não
 * daria para desligar uma preferência que hoje está ligada.
 */
public record AtualizarPreferenciasDTO(
    Boolean perfilPublico,
    Boolean permiteSolicitacoes,
    Boolean notificarNoApp,
    Boolean notificarEmail,
    Boolean compartilharLocalizacao,
    Boolean dadosDeUsoAnonimo) {

  /** Verdadeiro quando o corpo veio sem nenhum campo para mudar. */
  public boolean vazio() {
    return perfilPublico == null
        && permiteSolicitacoes == null
        && notificarNoApp == null
        && notificarEmail == null
        && compartilharLocalizacao == null
        && dadosDeUsoAnonimo == null;
  }
}
