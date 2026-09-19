package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoMissao;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class Missao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(nullable = false)
    private String Nome;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoMissao TipoDeMissao;

    @Column(nullable = false)
    private LocalDate TempoDeInicio;

    @Column(nullable = false)
    private LocalDate TempoLimite;

    @Column(nullable = false)
    private int MoedaRecompensa;

    @Column(nullable = false)
    private int XpRecompensa;


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNome() { return Nome; }
    public void setNome(String nome) { Nome = nome; }

    public TipoMissao getTipoDeMissao() { return TipoDeMissao; }
    public void setTipoDeMissao(TipoMissao tipoDeMissao) { TipoDeMissao = tipoDeMissao; }

    public LocalDate getTempoDeInicio() { return TempoDeInicio; }
    public void setTempoDeInicio(LocalDate tempoDeInicio) { TempoDeInicio = tempoDeInicio; }

    public LocalDate getTempoLimite() { return TempoLimite; }
    public void setTempoLimite(LocalDate tempoLimite) { TempoLimite = tempoLimite; }

    public int getMoedaRecompensa() { return MoedaRecompensa; }
    public void setMoedaRecompensa(int moedaRecompensa) { MoedaRecompensa = moedaRecompensa; }

    public int getXpRecompensa() { return XpRecompensa; }
    public void setXpRecompensa(int xpRecompensa) { XpRecompensa = xpRecompensa; }
}
