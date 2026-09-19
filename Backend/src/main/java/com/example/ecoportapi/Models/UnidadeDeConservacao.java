package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import jakarta.persistence.*;

@Entity
public class UnidadeDeConservacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(nullable = false)
    private String Nome;

    @Column(nullable = false)
    private String Localizacao;

    @Column(nullable = false)
    private Double IntegridadeTerritorial;

    @Column(nullable = false)
    private Double ConectividadeEcologica;

    @Column(nullable = false)
    private String Fiscalizacao; //Alta/Media/Baixa

    @Column(nullable = false)
    private String Biodiversidade; //Alta/Media/Baixa

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private TipoDeUnidade TipoDeUnidade;

    @Column(nullable = false)
    private Double Poluicao;

    @Column(nullable = false)
    private Double PreservacaoLocal;
}