package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoEspecie;
import jakarta.persistence.*;

/**
 * Uma espécie registrada na unidade de conservação.
 *
 * A imagem é uma URL: a tela só precisa do endereço para mostrar a foto.
 * Sem foto cadastrada a tela mostra um placeholder no lugar do card.
 */
@Entity
@Table(name = "Especie")
public class Especie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Unidade", nullable = false)
    private UnidadeDeConservacao Unidade;

    @Column(name = "Nome", nullable = false)
    private String Nome;

    @Column(name = "NomeCientifico", nullable = true)
    private String NomeCientifico;

    @Column(name = "Descricao", nullable = true)
    private String Descricao;

    @Column(name = "Imagem", nullable = true)
    private String Imagem;

    @Enumerated(EnumType.STRING)
    @Column(name = "Tipo", nullable = false)
    private TipoEspecie Tipo;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public UnidadeDeConservacao getUnidade() { return Unidade; }
    public void setUnidade(UnidadeDeConservacao unidade) { Unidade = unidade; }

    public String getNome() { return Nome; }
    public void setNome(String nome) { Nome = nome; }

    public String getNomeCientifico() { return NomeCientifico; }
    public void setNomeCientifico(String nomeCientifico) { NomeCientifico = nomeCientifico; }

    public String getDescricao() { return Descricao; }
    public void setDescricao(String descricao) { Descricao = descricao; }

    public String getImagem() { return Imagem; }
    public void setImagem(String imagem) { Imagem = imagem; }

    public TipoEspecie getTipo() { return Tipo; }
    public void setTipo(TipoEspecie tipo) { Tipo = tipo; }
}