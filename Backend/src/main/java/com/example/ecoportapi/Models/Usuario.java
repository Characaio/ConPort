package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Usuario")
public class Usuario {

  // perdao choracaio meu formatador fez alguma coisa ai. se nao gostou, sla, ngm mandou nao
  // aparecer
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "Id")
  private Long Id;

  @Column(name = "Nome", nullable = false)
  private String Nome;

  @Column(name = "DataNasc", nullable = false)
  private LocalDate DataNasc;

  @Column(name = "Email", nullable = false)
  private String Email;

  @Column(name = "Senha", nullable = false)
  private String Senha;

  @Column(name = "Estado", nullable = false)
  private String Estado;

  @Column(name = "Cidade", nullable = false)
  private String Cidade;

  @Column(name = "Confiavel", nullable = false)
  private Boolean Confiavel;

  @Column(name = "XP", nullable = false)
  private Integer XP;

  @Column(name = "Level", nullable = false)
  private Integer Level;

  @Column(name = "Moedas", nullable = false)
  private Integer Moedas;

  @Column(name = "Reputacao", nullable = false)
  private Double Reputacao;

  @Column(name = "Username", nullable = false, unique = true)
  private String Username;

  @Column(
      name = "DataCadastro",
      nullable = false,
      columnDefinition = "timestamp default CURRENT_TIMESTAMP")
  private LocalDateTime DataCadastro;

  @Column(name = "Avatar", nullable = true)
  private String Avatar;

  // O campo é "Visibilidade" e não "VisibilidadeSeguidores" porque esse é o
  // nome do enum: com os dois iguais o inicializador viraria
  // auto-referência.
  @Enumerated(EnumType.STRING)
  @Column(name = "Visibilidade", nullable = true)
  private VisibilidadeSeguidores Visibilidade = VisibilidadeSeguidores.PUBLICO;

  // ============================================================
  // PREFERÊNCIAS
  //
  // Estas vão para o banco (e não para o aparelho) por um motivo só: quem
  // entra na conta em outro celular espera encontrar as mesmas respostas de
  // antes. As preferências de aparência — tema, fonte, alto contraste — são
  // do aparelho, porque cada tela tem o próprio tamanho e a própria luz.
  //
  // Todo campo começa em `true` menos o compartilhamento de localização, que
  // é o padrão que já valia antes de existir a opção: nada era compartilhado.
  // Nulo no banco é lido como o padrão, então conta antiga não muda de
  // comportamento por causa de uma coluna nova.
  // ============================================================

  @Column(name = "PerfilPublico", nullable = true)
  private Boolean PerfilPublico = true;

  @Column(name = "PermiteSolicitacoes", nullable = true)
  private Boolean PermiteSolicitacoes = true;

  @Column(name = "NotificarNoApp", nullable = true)
  private Boolean NotificarNoApp = true;

  @Column(name = "NotificarEmail", nullable = true)
  private Boolean NotificarEmail = false;

  @Column(name = "CompartilharLocalizacao", nullable = true)
  private Boolean CompartilharLocalizacao = false;

  @Column(name = "DadosDeUsoAnonimo", nullable = true)
  private Boolean DadosDeUsoAnonimo = true;

  @PrePersist
  void prePersist() {
    if (DataCadastro == null) {
      DataCadastro = LocalDateTime.now();
    }
  }

  public Long getId() {
    return Id;
  }

  public void setId(Long id) {
    Id = id;
  }

  public String getNome() {
    return Nome;
  }

  public void setNome(String nome) {
    Nome = nome;
  }

  public LocalDate getDataNasc() {
    return DataNasc;
  }

  public void setDataNasc(LocalDate dataNasc) {
    DataNasc = dataNasc;
  }

  public String getEmail() {
    return Email;
  }

  public void setEmail(String email) {
    Email = email;
  }

  public String getSenha() {
    return Senha;
  }

  public void setSenha(String senha) {
    Senha = senha;
  }

  public String getEstado() {
    return Estado;
  }

  public void setEstado(String estado) {
    Estado = estado;
  }

  public String getCidade() {
    return Cidade;
  }

  public void setCidade(String cidade) {
    Cidade = cidade;
  }

  public Boolean isConfiavel() {
    return Confiavel;
  }

  public void setConfiavel(Boolean confiavel) {
    Confiavel = confiavel;
  }

  public Integer getXP() {
    return XP;
  }

  public void setXP(Integer XP) {
    this.XP = XP;
  }

  public Integer getLevel() {
    return Level;
  }

  public void setLevel(Integer level) {
    Level = level;
  }

  public Integer getMoedas() {
    return Moedas;
  }

  public void setMoedas(Integer moedas) {
    Moedas = moedas;
  }

  public Double getReputacao() {
    return Reputacao;
  }

  public void setReputacao(Double reputacao) {
    Reputacao = reputacao;
  }

  public String getUsername() {
    return Username;
  }

  public void setUsername(String username) {
    Username = username;
  }

  public LocalDateTime getDataCadastro() {
    return DataCadastro;
  }

  public void setDataCadastro(LocalDateTime dataCadastro) {
    DataCadastro = dataCadastro;
  }

  public String getAvatar() {
    return Avatar;
  }

  public void setAvatar(String avatar) {
    Avatar = avatar;
  }

  public VisibilidadeSeguidores getVisibilidade() {
    return Visibilidade;
  }

  public void setVisibilidade(VisibilidadeSeguidores visibilidade) {
    Visibilidade = visibilidade;
  }

  // Cada getter resolve o nulo para o padrão em vez de devolver null: assim
  // quem lê não precisa repetir o "e se for null?" em toda parte, e a conta
  // antiga se comporta como se a preferência tivesse sido sempre a padrão.

  public boolean isPerfilPublico() {
    return PerfilPublico == null || PerfilPublico;
  }

  public void setPerfilPublico(Boolean perfilPublico) {
    PerfilPublico = perfilPublico;
  }

  public boolean isPermiteSolicitacoes() {
    return PermiteSolicitacoes == null || PermiteSolicitacoes;
  }

  public void setPermiteSolicitacoes(Boolean permiteSolicitacoes) {
    PermiteSolicitacoes = permiteSolicitacoes;
  }

  public boolean isNotificarNoApp() {
    return NotificarNoApp == null || NotificarNoApp;
  }

  public void setNotificarNoApp(Boolean notificarNoApp) {
    NotificarNoApp = notificarNoApp;
  }

  public boolean isNotificarEmail() {
    return NotificarEmail != null && NotificarEmail;
  }

  public void setNotificarEmail(Boolean notificarEmail) {
    NotificarEmail = notificarEmail;
  }

  public boolean isCompartilharLocalizacao() {
    return CompartilharLocalizacao != null && CompartilharLocalizacao;
  }

  public void setCompartilharLocalizacao(Boolean compartilharLocalizacao) {
    CompartilharLocalizacao = compartilharLocalizacao;
  }

  public boolean isDadosDeUsoAnonimo() {
    return DadosDeUsoAnonimo == null || DadosDeUsoAnonimo;
  }

  public void setDadosDeUsoAnonimo(Boolean dadosDeUsoAnonimo) {
    DadosDeUsoAnonimo = dadosDeUsoAnonimo;
  }
}
