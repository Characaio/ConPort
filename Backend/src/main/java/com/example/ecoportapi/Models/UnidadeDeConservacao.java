package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import jakarta.persistence.*;

@Entity
@Table(name = "UnidadeDeConservacao")
public class UnidadeDeConservacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @Column(name = "Nome", nullable = false)
    private String Nome;

    @Column(name = "Localizacao", nullable = false)
    private String Localizacao;

    @Enumerated(EnumType.STRING)
    @Column(name = "TipoDeUnidade", nullable = false)
    private TipoDeUnidade TipoDeUnidade;


    //Dados internos da unidade
    //Informações base para derivar novos indicadores de status
    //Essas informações serão acessiveis na area de mais informações sobre essa unidade
    @Column(name = "AreaTotal", nullable = false)
    private Double AreaTotal;

    @Column(name = "AreaRegularizada", nullable = false)
    private Double AreaRegularizada;

    @Column(name = "AreaPreservada", nullable = false)
    private Double AreaPreservada;

    @Column(name = "AreaMonitorada", nullable = false)
    private Double AreaMonitorada;

    @Column(name = "AreaComConectividade", nullable = false)
    private Double AreaComConectividade;

    @Column(name = "QuantidadeCorredores", nullable = false)
    private Integer QuantidadeCorredores;

    @Column(name = "QuantidadeEspecies", nullable = false)
    private Integer QuantidadeEspecies;

    @Column(name = "QuantidadeEspeciesEsperadas", nullable = false)
    private Integer QuantidadeEspeciesEsperadas;


    //Dados utilizados para calcular a Qualidade Ambiental
    //Valores de 0 a 100, onde 100 representa a melhor condição
    @Column(name = "QualidadeAgua", nullable = false)
    private Double QualidadeAgua;

    @Column(name = "QualidadeSolo", nullable = false)
    private Double QualidadeSolo;

    @Column(name = "GestaoResiduos", nullable = false)
    private Double GestaoResiduos;


    //Indicadores Principais de status
    //Alguns desses indicadores serão derivados dos indicadores internos
    //Esses serão so status principais da unidade
    @Column(name = "IntegridadeTerritorial", nullable = false)
    private Double IntegridadeTerritorial;

    @Column(name = "ConectividadeEcologica", nullable = false)
    private Double ConectividadeEcologica;

    @Column(name = "QualidadeAmbiental", nullable = false)
    private Double QualidadeAmbiental;

    @Column(name = "PreservacaoLocal", nullable = false)
    private Double PreservacaoLocal;

    //Informações sobre os dois proximos indicadores
    //Eles serão transformados em Alto/Medio/Baixo ao chegar no FrontEnd
    //O valor em porcentagem será acessivel na tela de mais informacoes sobre a unidade
    //Isso é para simplificar o consumo de informações do usuario
    @Column(name = "Fiscalizacao", nullable = false)
    private Double Fiscalizacao;

    @Column(name = "Biodiversidade", nullable = false)
    private Double Biodiversidade;


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNome() { return Nome; }
    public void setNome(String nome) { Nome = nome; }

    public String getLocalizacao() { return Localizacao; }
    public void setLocalizacao(String localizacao) { Localizacao = localizacao; }

    public TipoDeUnidade getTipoDeUnidade() { return TipoDeUnidade; }
    public void setTipoDeUnidade(TipoDeUnidade tipoDeUnidade) { TipoDeUnidade = tipoDeUnidade; }

    public Double getAreaTotal() { return AreaTotal; }
    public void setAreaTotal(Double areaTotal) { AreaTotal = areaTotal; }

    public Double getAreaRegularizada() { return AreaRegularizada; }
    public void setAreaRegularizada(Double areaRegularizada) { AreaRegularizada = areaRegularizada; }

    public Double getAreaPreservada() { return AreaPreservada; }
    public void setAreaPreservada(Double areaPreservada) { AreaPreservada = areaPreservada; }

    public Double getAreaMonitorada() { return AreaMonitorada; }
    public void setAreaMonitorada(Double areaMonitorada) { AreaMonitorada = areaMonitorada; }

    public Double getAreaComConectividade() { return AreaComConectividade; }
    public void setAreaComConectividade(Double areaComConectividade) { AreaComConectividade = areaComConectividade; }

    public Integer getQuantidadeCorredores() { return QuantidadeCorredores; }
    public void setQuantidadeCorredores(Integer quantidadeCorredores) { QuantidadeCorredores = quantidadeCorredores; }

    public Integer getQuantidadeEspecies() { return QuantidadeEspecies; }
    public void setQuantidadeEspecies(Integer quantidadeEspecies) { QuantidadeEspecies = quantidadeEspecies; }

    public Integer getQuantidadeEspeciesEsperadas() { return QuantidadeEspeciesEsperadas; }
    public void setQuantidadeEspeciesEsperadas(Integer quantidadeEspeciesEsperadas) { QuantidadeEspeciesEsperadas = quantidadeEspeciesEsperadas; }

    public Double getQualidadeAgua() { return QualidadeAgua; }
    public void setQualidadeAgua(Double qualidadeAgua) { QualidadeAgua = qualidadeAgua; }

    public Double getQualidadeSolo() { return QualidadeSolo; }
    public void setQualidadeSolo(Double qualidadeSolo) { QualidadeSolo = qualidadeSolo; }

    public Double getGestaoResiduos() { return GestaoResiduos; }
    public void setGestaoResiduos(Double gestaoResiduos) { GestaoResiduos = gestaoResiduos; }

    public Double getIntegridadeTerritorial() { return IntegridadeTerritorial; }
    public void setIntegridadeTerritorial(Double integridadeTerritorial) { IntegridadeTerritorial = integridadeTerritorial; }

    public Double getConectividadeEcologica() { return ConectividadeEcologica; }
    public void setConectividadeEcologica(Double conectividadeEcologica) { ConectividadeEcologica = conectividadeEcologica; }

    public Double getQualidadeAmbiental() { return QualidadeAmbiental; }
    public void setQualidadeAmbiental(Double qualidadeAmbiental) { QualidadeAmbiental = qualidadeAmbiental; }

    public Double getPreservacaoLocal() { return PreservacaoLocal; }
    public void setPreservacaoLocal(Double preservacaoLocal) { PreservacaoLocal = preservacaoLocal; }

    public Double getFiscalizacao() { return Fiscalizacao; }
    public void setFiscalizacao(Double fiscalizacao) { Fiscalizacao = fiscalizacao; }

    public Double getBiodiversidade() { return Biodiversidade; }
    public void setBiodiversidade(Double biodiversidade) { Biodiversidade = biodiversidade; }
}