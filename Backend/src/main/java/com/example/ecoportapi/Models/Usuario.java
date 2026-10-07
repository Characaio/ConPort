package com.example.ecoportapi.Models;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "Usuario")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @Column(name = "Username", nullable = false)
    private String Username;

    @Column(name = "DataNasc", nullable = false)
    private LocalDate DataNasc;

    @Column(name = "Email", nullable = false,unique = true)
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

    @Column(name = "Reputacao",nullable = false)
    private Double Reputacao;

    @Column(name = "AvatarImagemURL",nullable = true)
    private String AvatarImagemCaminho;


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNome() { return Username; }
    public void setNome(String username) { Username = username; }

    public LocalDate getDataNasc() { return DataNasc; }
    public void setDataNasc(LocalDate dataNasc) { DataNasc = dataNasc; }

    public String getEmail() { return Email; }
    public void setEmail(String email) { Email = email; }

    public String getSenha() { return Senha; }
    public void setSenha(String senha) { Senha = senha; }

    public String getEstado() { return Estado; }
    public void setEstado(String estado) { Estado = estado; }

    public String getCidade() { return Cidade; }
    public void setCidade(String cidade) { Cidade = cidade; }

    public Boolean isConfiavel() { return Confiavel; }
    public void setConfiavel(Boolean confiavel) { Confiavel = confiavel; }

    public Integer getXP() { return XP; }
    public void setXP(Integer XP) { this.XP = XP; }

    public Integer getLevel() { return Level; }
    public void setLevel(Integer level) { Level = level; }

    public Integer getMoedas() { return Moedas; }
    public void setMoedas(Integer moedas) { Moedas = moedas; }

    public Double getReputacao() { return Reputacao; }
    public void setReputacao(Double reputacao) { Reputacao = reputacao; }

    public String getAvatarImagemCaminho(){ return AvatarImagemCaminho; }
    public void setAvatarImagemCaminho(String avatarImagemCaminho){AvatarImagemCaminho = avatarImagemCaminho;}
}