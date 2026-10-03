package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "UsuarioRelacionamento",
    uniqueConstraints = @UniqueConstraint(columnNames = {"Seguidor_id", "Seguindo_id"}))
public class UsuarioRelacionamento {

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

  @Enumerated(EnumType.STRING)
  @Column(name = "Status", nullable = false)
  private StatusRelacionamento Status = StatusRelacionamento.PENDENTE;

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

  public StatusRelacionamento getStatus() {
    return Status;
  }

  public void setStatus(StatusRelacionamento status) {
    Status = status;
  }

  public LocalDateTime getDataCriacao() {
    return DataCriacao;
  }

  public void setDataCriacao(LocalDateTime dataCriacao) {
    DataCriacao = dataCriacao;
  }
}
