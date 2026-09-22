package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
public class Missao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Usuario", nullable = false)
    private Usuario Usuario;

    @Column(name = "Titulo", nullable = false)
    private String Titulo;

    @Column(name = "Descricao", nullable = false)
    private String Descricao;

    @Enumerated(EnumType.STRING)
    @Column(name = "TipoDeMissao", nullable = false)
    private TipoMissao TipoDeMissao;

    @Enumerated(EnumType.STRING)
    @Column(name = "StatusMissao",nullable = false)
    private StatusMissao StatusMissao;

    @Column(name = "Meta", nullable = false)
    private Integer Meta;

    @Column(name = "Progresso",nullable = false)
    private Integer Progresso;

    @Column(name = "TempoDeInicio",nullable = false)
    private LocalDateTime TempoDeInicio;

    @Column(name = "TempoFechamento", nullable = false)
    private LocalDateTime TempoFechamento;

    @Column(name = "MoedaRecompensa", nullable = false)
    private Integer MoedaRecompensa;

    @Column(name = "XpRecompensa", nullable = false)
    private Integer XpRecompensa;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { Usuario = usuario; }

    public String getTitulo() { return Titulo; }
    public void setTitulo(String titulo) { Titulo = titulo; }

    public String getDescricao() { return Descricao; }
    public void setDescricao(String descricao) { Descricao = descricao; }

    public TipoMissao getTipoDeMissao() { return TipoDeMissao; }
    public void setTipoDeMissao(TipoMissao tipoDeMissao) { TipoDeMissao = tipoDeMissao; }

    public StatusMissao getStatusMissao() { return StatusMissao; }
    public void setStatusMissao(StatusMissao statusMissao) { StatusMissao = statusMissao; }

    public Integer getMeta() { return Meta; }
    public void setMeta(Integer meta) { Meta = meta;}

    public Integer getProgresso() { return Progresso; }
    public void setProgresso(Integer progresso) { Progresso = progresso;}

    public LocalDateTime getTempoDeInicio() { return TempoDeInicio; }
    public void setTempoDeInicio(LocalDateTime tempoDeInicio) { TempoDeInicio = tempoDeInicio; }

    public LocalDateTime getTempoFechamento() { return TempoFechamento; }
    public void setTempoFechamento(LocalDateTime tempoLimite) { TempoFechamento = tempoLimite; }

    public int getMoedaRecompensa() { return MoedaRecompensa; }
    public void setMoedaRecompensa(int moedaRecompensa) { MoedaRecompensa = moedaRecompensa; }

    public int getXpRecompensa() { return XpRecompensa; }
    public void setXpRecompensa(int xpRecompensa) { XpRecompensa = xpRecompensa; }

}
