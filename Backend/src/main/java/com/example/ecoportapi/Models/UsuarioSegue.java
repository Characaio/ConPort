package com.example.ecoportapi.Models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Quem segue quem.
 *
 * <p>Fica numa tabela separada de {@link UsuarioRelacionamento} de propósito.
 * A amizade é bilateral e passa por um pedido; o follow é unilateral e
 * imediato. Se dividissem a tabela, o índice único
 * {@code (Seguidor_id, Seguindo_id)} impediria seguir alguém e, ao mesmo
 * tempo, ter um pedido de amizade em andamento com a mesma pessoa — que são
 * exatamente as duas ações que o perfil oferece.
 */
@Entity
@Table(
    name = "UsuarioSegue",
    uniqueConstraints = @UniqueConstraint(columnNames = {"Seguidor_id", "Seguindo_id"}))
public class UsuarioSegue {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "Id")
  private Long Id;

  @ManyToOne
  @JoinColumn(name = "Seguidor_id", nullable = false)
  private Usuario Seguidor;

  @ManyToOne
  @JoinColumn(name = "Seguindo_id", nullable = false)
  private Usuario Seguindo;

  @Column(name = "DataCriacao", nullable = false)
  private LocalDateTime DataCriacao = LocalDateTime.now();

  public Long getId() {
    return Id;
  }

  public void setId(Long id) {
    Id = id;
  }

  public Usuario getSeguidor() {
    return Seguidor;
  }

  public void setSeguidor(Usuario seguidor) {
    Seguidor = seguidor;
  }

  public Usuario getSeguindo() {
    return Seguindo;
  }

  public void setSeguindo(Usuario seguindo) {
    Seguindo = seguindo;
  }

  public LocalDateTime getDataCriacao() {
    return DataCriacao;
  }

  public void setDataCriacao(LocalDateTime dataCriacao) {
    DataCriacao = dataCriacao;
  }
}
