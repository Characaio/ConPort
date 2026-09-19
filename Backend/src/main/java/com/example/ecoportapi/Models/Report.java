package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.util.List;

@Entity
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario Usuario;

    @OneToOne
    @JoinColumn(name = "supervisor_id", nullable = false)
    private SupervisorDeUnidade Supervisor;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoDeIncidente Tipo;

    @Column(nullable = false)
    private String Descricao;

    @Column(nullable = false)
    private LocalDate DataDoOcorrido;

    @Column(nullable = false)
    private String Local;

    @Column(nullable = true)
    private LocalDate DataDaAnalise;

    @ElementCollection
    private List<String> ImagensRelacionadas;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusReport Status;


    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { this.Usuario = usuario; }

    public SupervisorDeUnidade getSupervisor() { return Supervisor; }
    public void setSupervisor(SupervisorDeUnidade supervisor) { this.Supervisor = supervisor; }

    public TipoDeIncidente getTipo() { return Tipo; }
    public void setTipo(TipoDeIncidente tipo) { Tipo = tipo; }

    public String getDescricao() { return Descricao; }
    public void setDescricao(String descricao) { Descricao = descricao; }

    public LocalDate getDataDoOcorrido() { return DataDoOcorrido; }
    public void setDataDoOcorrido(LocalDate dataDoOcorrido) { DataDoOcorrido = dataDoOcorrido; }

    public String getLocal() { return Local; }
    public void setLocal(String local) { Local = local; }

    public LocalDate getDataDaAnalisa() { return DataDaAnalise; }
    public void setDataDaAnalisa(LocalDate dataDaAnalisa) { DataDaAnalise = dataDaAnalisa; }

    public List<String> getImagensRelacionadas() { return ImagensRelacionadas; }
    public void setImagensRelacionadas(List<String> imagensRelacionadas) { ImagensRelacionadas = imagensRelacionadas; }

    public StatusReport getStatus() { return Status; }
    public void setStatus(StatusReport status) { Status = status; }
}