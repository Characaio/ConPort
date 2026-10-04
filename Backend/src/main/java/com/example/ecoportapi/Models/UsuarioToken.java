package com.example.ecoportapi.Models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Sessão de um usuário: o token que o app manda no header.
 *
 * <p>É uma chave aleatória guardada no banco, e não um JWT, por dois motivos
 * práticos: dá para revogar na hora (o "sair da conta" funciona de verdade)
 * e não exige nenhuma biblioteca de criptografia no backend. O preço é uma
 * consulta ao banco por requisição autenticada.
 */
@Entity
@Table(name = "UsuarioToken")
public class UsuarioToken {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "Id")
  private Long Id;

  /**
   * A chave em si. Vai no header {@code Authorization: Bearer ...}, então é
   * o que roubar uma sessão. Índice único é o que impede colisão e o que
   * torna a busca por token rápida.
   */
  @Column(name = "Token", nullable = false, unique = true, length = 100)
  private String Token;

  @ManyToOne
  @JoinColumn(name = "Usuario_id", nullable = false)
  private Usuario Usuario;

  @Column(name = "DataCriacao", nullable = false)
  private LocalDateTime DataCriacao = LocalDateTime.now();

  @Column(name = "DataExpiracao", nullable = false)
  private LocalDateTime DataExpiracao;

  @Column(name = "UltimoUso", nullable = true)
  private LocalDateTime UltimoUso;

  public Long getId() {
    return Id;
  }

  public void setId(Long id) {
    Id = id;
  }

  public String getToken() {
    return Token;
  }

  public void setToken(String token) {
    Token = token;
  }

  public Usuario getUsuario() {
    return Usuario;
  }

  public void setUsuario(Usuario usuario) {
    Usuario = usuario;
  }

  public LocalDateTime getDataCriacao() {
    return DataCriacao;
  }

  public void setDataCriacao(LocalDateTime dataCriacao) {
    DataCriacao = dataCriacao;
  }

  public LocalDateTime getDataExpiracao() {
    return DataExpiracao;
  }

  public void setDataExpiracao(LocalDateTime dataExpiracao) {
    DataExpiracao = dataExpiracao;
  }

  public LocalDateTime getUltimoUso() {
    return UltimoUso;
  }

  public void setUltimoUso(LocalDateTime ultimoUso) {
    UltimoUso = ultimoUso;
  }
}
