package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Report")
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Unidade",nullable = false)
    private UnidadeDeConservacao Unidade;

    @ManyToOne
    @JoinColumn(name = "Usuario", nullable = false)
    private Usuario Usuario;

    @ManyToOne
    @JoinColumn(name = "Supervisor", nullable = true)
    private SupervisorDeUnidade Supervisor;

    @Enumerated(EnumType.STRING)
    @Column(name = "Tipo", nullable = false)
    private TipoDeIncidente Tipo;

    @Column(name = "Descricao", nullable = false)
    private String Descricao;

    @Column(name = "DataDoOcorrido", nullable = false)
    private LocalDateTime DataDoOcorrido;

    @Column(name = "DataDaAnalise", nullable = true)
    private LocalDateTime DataDaAnalise;

    @Column(name = "MotivoDaNegacao", nullable = true)
    private String MotivoDaNegacao;

    @ElementCollection
    @Column(name = "ImagensAnexadas", nullable = true)
    private List<String> ImagensAnexadas = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "Status", nullable = false)
    private StatusReport Status;


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public UnidadeDeConservacao getUnidade() { return Unidade; }
    public void setUnidade(UnidadeDeConservacao unidade) { this.Unidade = unidade; }


    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { this.Usuario = usuario; }

    public SupervisorDeUnidade getSupervisor() { return Supervisor; }
    public void setSupervisor(SupervisorDeUnidade supervisor) { this.Supervisor = supervisor; }

    public TipoDeIncidente getTipo() { return Tipo; }
    public void setTipo(TipoDeIncidente tipo) { Tipo = tipo; }

    public String getDescricao() { return Descricao; }
    public void setDescricao(String descricao) { Descricao = descricao; }

    public LocalDateTime getDataDoOcorrido() { return DataDoOcorrido; }
    public void setDataDoOcorrido(LocalDateTime dataDoOcorrido) { DataDoOcorrido = dataDoOcorrido; }

    public LocalDateTime getDataDaAnalisa() { return DataDaAnalise; }
    public void setDataDaAnalisa(LocalDateTime dataDaAnalise) { DataDaAnalise = dataDaAnalise; }

    public String getMotivoDaNegacao() { return MotivoDaNegacao; }
    public void setMotivoDaNegacao(String motivoDaNegacao) { MotivoDaNegacao = motivoDaNegacao; }

    public List<String> getImagensAnexadas() { return ImagensAnexadas; }
    public void setImagensAnexadas(List<String> imagensAnexadas) { ImagensAnexadas = imagensAnexadas; }

    public StatusReport getStatus() { return Status; }
    public void setStatus(StatusReport status) { Status = status; }
}