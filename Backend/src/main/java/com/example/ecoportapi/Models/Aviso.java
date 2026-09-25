package com.example.ecoportapi.Models;


import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "Aviso")
public class Aviso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Unidade", nullable = false)
    private UnidadeDeConservacao Unidade;

    @Column(name = "Titulo", nullable = false)
    private String Titulo;

    @Column(name = "Conteudo", nullable = false)
    private String Conteudo;

    @Column(name = "HorarioDoAviso", nullable = false)
    private LocalDateTime HorarioDoAviso;

    public Long getId() {return Id; }
    public void setId(Long id) {Id = id;}

    public UnidadeDeConservacao getUnidade() {return Unidade;}
    public void setUnidade(UnidadeDeConservacao unidade) {Unidade = unidade;}

    public String getTitulo() {return Titulo;}
    public void setTitulo(String titulo) {Titulo = titulo;}

    public String getConteudo() {return Conteudo;}
    public void setConteudo(String conteudo) {Conteudo = conteudo;}

    public LocalDateTime getHorarioDoAviso() {return HorarioDoAviso;}
    public void setHorarioDoAviso(LocalDateTime horarioDoAviso) {HorarioDoAviso = horarioDoAviso;}

}
