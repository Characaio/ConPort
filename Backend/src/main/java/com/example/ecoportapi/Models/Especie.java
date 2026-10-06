package com.example.ecoportapi.Models;

import com.example.ecoportapi.DTOs.Response.ImagemDireitos;
import com.example.ecoportapi.Models.Enums.PerigoDeExtincao;
import com.example.ecoportapi.Models.Enums.ReinoBioGeografico;
import com.example.ecoportapi.Models.Enums.TendenciaPopulacional;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Especie")
public class Especie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id", nullable = false)
    private Long Id;

    @Column(name = "NomeCientifico", nullable = false)
    private String NomeCientifico;

    @Column(name = "NomeComum", nullable = false)
    private String NomeComum;

    @Column(name = "Reino", nullable = false)
    private String Reino;

    @Column(name = "Filo", nullable = false)
    private String Filo;

    @Column(name = "Classe", nullable = false)
    private String Classe;

    @Column(name = "Ordem", nullable = false)
    private String Ordem;

    @Column(name = "Familia", nullable = false)
    private String Familia;

    @Column(name = "Genus", nullable = false)
    private String Genus;

    @Column(name = "Especie", nullable = false)
    private String Especie;

    @Column(columnDefinition = "TEXT", name = "DescricaoResumida", nullable = false)
    private String DescricaoResumida;

    @Column(columnDefinition = "TEXT",name = "DescricaoExpandida", nullable = false)
    private String DescricaoExpandida;

    @ElementCollection
    @Column(name = "Habitats", nullable = false)
    private List<String> Habitats = new ArrayList<>();

    @ElementCollection
    @Column(name = "ReinoBioGeografico", nullable = false)
    private List<ReinoBioGeografico> ReinoBioGeografico = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "PerigoDeExtincao", nullable = false)
    private PerigoDeExtincao PerigoDeExtincao;

    @Enumerated(EnumType.STRING)
    @Column(name = "TendenciaPopulacional")
    private TendenciaPopulacional TendenciaPopulacional;

    @Column(columnDefinition = "TEXT", name = "ImagemThumb", nullable = false)
    private String ImagemThumb;

    @Column(columnDefinition = "TEXT", name = "ImagemOriginal", nullable = false)
    private String ImagemOriginal;

    @Column(name = "AutorDaImagem", nullable = false)
    private String AutorDaImagem;

    @Column(columnDefinition = "TEXT", name = "ImagLicencaemOriginal", nullable = false)
    private String Licenca;

    @Column(columnDefinition = "TEXT", name = "TermosDeUso", nullable = false)
    private String TermosDeUso;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNomeCientifico() { return NomeCientifico; }
    public void setNomeCientifico(String nomeCientifico) { NomeCientifico = nomeCientifico; }

    public String getNomeComum() { return NomeComum; }
    public void setNomeComum(String nomeComum) { NomeComum = nomeComum; }

    public String getReino() { return Reino; }
    public void setReino(String reino) { Reino = reino; }

    public String getFilo() { return Filo;}
    public void setFilo(String filo) { Filo = filo; }

    public String getClasse() { return Classe; }
    public void setClasse(String classe) { Classe = classe; }

    public String getOrdem() { return Ordem; }
    public void setOrdem(String ordem) { Ordem = ordem; }

    public String getFamilia() { return Familia; }
    public void setFamilia(String familia) { Familia = familia; }

    public String getGenus() { return Genus; }
    public void setGenus(String genero) { Genus = genero; }

    public String getEspecie() { return Especie; }
    public void setEspecie(String especie) { Especie = especie; }

    public String getDescricaoResumida() { return DescricaoResumida; }
    public void setDescricaoResumida(String descricaoCurta) { DescricaoResumida = descricaoCurta; }

    public String getDescricaoExpandida() { return DescricaoExpandida; }
    public void setDescricaoExpandida(String descricaoExpandida) { DescricaoExpandida = descricaoExpandida; }

    public List<String> getHabitats() { return Habitats; }
    public void setHabitats(List<String> habitats) { Habitats = habitats; }

    public List<ReinoBioGeografico> getReinosBioGeograficos() { return ReinoBioGeografico; }
    public void setReinosBioGeograficos(List<ReinoBioGeografico> reinoBioGeografico) { ReinoBioGeografico = reinoBioGeografico; }

    public PerigoDeExtincao getPerigoDeExtincao() { return PerigoDeExtincao; }
    public void setPerigoDeExtincao(PerigoDeExtincao perigoDeExtincao) { PerigoDeExtincao = perigoDeExtincao; }

    public TendenciaPopulacional getTendenciaPopulacional() { return TendenciaPopulacional; }
    public void setTendenciaPopulacional(TendenciaPopulacional tendenciaPopulacional) { TendenciaPopulacional = tendenciaPopulacional; }

    public String getImagemURLThumb() { return ImagemThumb; }
    public void setImagemURLThumb(String imagem) { ImagemThumb = imagem; }

    public String getImagemURLOriginal() { return ImagemOriginal; }
    public void setImagemURLOriginal(String imagem) { ImagemOriginal = imagem; }

    public String getAutorDaImagem() { return AutorDaImagem; }
    public void setAutorDaImagem(String autorDaImagem){ AutorDaImagem = autorDaImagem; }

    public String getLicenca() { return Licenca; }
    public void setLicenca(String licensa){ Licenca = licensa; }

    public String getTermosDeUso() { return TermosDeUso; }
    public void setTermosDeUso(String termosDeUso){ TermosDeUso = termosDeUso; }

}