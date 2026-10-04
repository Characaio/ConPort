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

    // Fixo aparece no topo da lista de anuncios da unidade. A coluna e
    // anulavel para o ddl-auto conseguir adicionar a coluna numa tabela que
    // ja tem linhas.
    @Column(name = "Fixo", nullable = true)
    private Boolean Fixo = false;

    // URL da foto do aviso; sem ela a tela mostra o card sem imagem.
    @Column(name = "Imagem", nullable = true)
    private String Imagem;

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

    public Boolean getFixo() {return Fixo;}
    public void setFixo(Boolean fixo) {Fixo = fixo;}

    public String getImagem() {return Imagem;}
    public void setImagem(String imagem) {Imagem = imagem;}

}
