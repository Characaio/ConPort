package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import jakarta.persistence.*;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.time.LocalDateTime;
import java.time.LocalTime;

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

    @Column(name = "Bioma", nullable = false)
    private String Bioma;

    //Telefone guardado de forma bruta, a mascara deve ser aplicada no FrontEnd
    @Column(name = "Telefone",nullable = false)
    private String Telefone;

    @Column(name = "HoraDeAbertura",nullable = false)
    private LocalTime HoraDeAbertura;

    @Column(name = "HoraDeFechamento")
    private LocalTime HoraDeFechamento;

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

    @Column(name = "AreaBasePorCorredor", nullable = false)
    private Double AreaBasePorCorredor;

    @Column(name = "PontosMonitorados", nullable = false)
    private Integer PontosMonitorados;

    @Column(name = "PontosPrevistos", nullable = false)
    private Integer PontosPrevistos;


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


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public String getNome() { return Nome; }
    public void setNome(String nome) { Nome = nome; }

    public String getLocalizacao() { return Localizacao; }
    public void setLocalizacao(String localizacao) { Localizacao = localizacao; }

    public String getBioma() { return Bioma; }
    public void setBioma(String bioma) { Bioma = bioma; }

    public String getTelefone(){ return Telefone; }
    public void setTelefone(String telefone){ Telefone = telefone; }

    public LocalTime getHoraAbertura(){ return HoraDeAbertura; }
    public void setHoraAbertura(LocalTime horaAbertura){ HoraDeAbertura = horaAbertura; }

    public LocalTime getHoraFechamento(){ return HoraDeFechamento ; }
    public void setHoraFechamento(LocalTime horaFechamento){ HoraDeFechamento = horaFechamento; }

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

    public Double getAreaBasePorCorredor() { return AreaBasePorCorredor; }
    public void setAreaBasePorCorredor(Double areaBasePorCorredor) { AreaBasePorCorredor = areaBasePorCorredor; }

    public Integer getQuantidadeCorredores() { return QuantidadeCorredores; }
    public void setQuantidadeCorredores(Integer quantidadeCorredores) { QuantidadeCorredores = quantidadeCorredores; }

    public Integer getPontosMonitorados() {return PontosMonitorados;}
    public void setPontosMonitorados(Integer pontosMonitorados){PontosMonitorados = pontosMonitorados; }

    public Integer getPontosPrevistos() {return PontosPrevistos;}
    public void setPontosPrevistos(Integer pontosPrevistos){PontosPrevistos = pontosPrevistos; }

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

}