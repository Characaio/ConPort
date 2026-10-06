package com.example.ecoportapi.Models;

import jakarta.persistence.*;
import org.hibernate.generator.values.GeneratedValueBasicResultBuilder;

@Entity
@Table(name = "UnidadeEspecie")
public class UnidadeEspecie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "UnidadeId", nullable = false)
    private UnidadeDeConservacao Unidade;

    @ManyToOne
    @JoinColumn(name = "EspecieId",nullable = false)
    private Especie Especie;

    public Long getId() {return Id;}

    public void setId(Long id) {Id = id;}

    public UnidadeDeConservacao getUnidade(){ return Unidade;}
    public void setUnidade(UnidadeDeConservacao unidade){ Unidade = unidade; }

    public Especie getEspecie(){ return Especie;}
    public void setEspecie(Especie especie){ Especie = especie; }
}
