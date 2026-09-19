package com.example.ecoportapi.Models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

import java.time.LocalDate;

@Entity
public class Usuario {
    @Column(nullable = false)
    private Long Id;

    @Column(nullable = false)
    private String Nome;

    @Column(nullable = false)
    private LocalDate DataNasc;

    @Column(nullable = false)
    private String Email;

    @Column(nullable = false)
    private String Senha;

    @Column(nullable = false)
    private boolean Confiavel;

    @Column(nullable = false)
    private int XP;

    @Column(nullable = false)
    private int Level;

    @Column(nullable = false)
    private int Moedas;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNome() { return Nome; }
    public void setNome(String nome) { Nome = nome; }

    public LocalDate getDataNasc() { return DataNasc; }
    public void setDataNasc(LocalDate dataNasc) { DataNasc = dataNasc; }

    public String getEmail() { return Email; }
    public void setEmail(String email) { Email = email; }

    public String getSenha() { return Senha; }
    public void setSenha(String senha) { Senha = senha; }

    public boolean isConfiavel() { return Confiavel; }
    public void setConfiavel(boolean confiavel) { Confiavel = confiavel; }

    public int getXP() { return XP; }
    public void setXP(int XP) { this.XP = XP; }

    public int getLevel() { return Level; }
    public void setLevel(int level) { Level = level; }

    public int getMoedas() { return Moedas; }
    public void setMoedas(int moedas) { Moedas = moedas; }


}
