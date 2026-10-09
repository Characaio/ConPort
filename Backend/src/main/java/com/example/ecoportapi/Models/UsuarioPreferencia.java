package com.example.ecoportapi.Models;


import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;
import jakarta.persistence.*;

@Entity
@Table(name = "UsuarioPreferencia")
public class UsuarioPreferencia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;

    @OneToOne
    @JoinColumn(name = "UsuarioId", nullable = false, unique = true)
    private Usuario UsuarioDono;

    @Column(name = "PerfilPublico", nullable = false)
    private boolean PerfilPublico = true;

    @Column(name = "PermiteSolicitacoes", nullable = false)
    private boolean PermiteSolicitacoes = true;

    @Column(name = "NotificarNoApp", nullable = false)
    private boolean NotificarNoApp = true;

    @Column(name = "NotificarEmail", nullable = false)
    private boolean NotificarEmail = false;

    @Column(name = "CompartilharLocalizacao", nullable = false)
    private boolean CompartilharLocalizacao = false;

    @Column(name = "DadosDeUsoAnonimo", nullable = false)
    private boolean DadosDeUsoAnonimo = true;

    @Enumerated(EnumType.STRING)
    @Column(name = "Visibilidade")
    private VisibilidadeSeguidores Visibilidade = VisibilidadeSeguidores.PUBLICO;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Usuario getUsuarioDono() { return UsuarioDono; }
    public void setUsuarioDono(Usuario usuarioDono) { this.UsuarioDono = usuarioDono; }

    public boolean isPerfilPublico() { return PerfilPublico; }
    public void setPerfilPublico(boolean perfilPublico) { this.PerfilPublico = perfilPublico; }

    public boolean isPermiteSolicitacoes() { return PermiteSolicitacoes; }
    public void setPermiteSolicitacoes(boolean permiteSolicitacoes) { this.PermiteSolicitacoes = permiteSolicitacoes; }

    public boolean isNotificarNoApp() { return NotificarNoApp; }
    public void setNotificarNoApp(boolean notificarNoApp) { this.NotificarNoApp = notificarNoApp; }

    public boolean isNotificarEmail() { return NotificarEmail; }
    public void setNotificarEmail(boolean notificarEmail) { this.NotificarEmail = notificarEmail; }

    public boolean isCompartilharLocalizacao() { return CompartilharLocalizacao; }
    public void setCompartilharLocalizacao(boolean compartilharLocalizacao) { this.CompartilharLocalizacao = compartilharLocalizacao; }

    public boolean isDadosDeUsoAnonimo() { return DadosDeUsoAnonimo; }
    public void setDadosDeUsoAnonimo(boolean dadosDeUsoAnonimo) { this.DadosDeUsoAnonimo = dadosDeUsoAnonimo; }

    public VisibilidadeSeguidores getVisibilidade() { return Visibilidade; }
    public void setVisibilidade(VisibilidadeSeguidores visibilidade) { this.Visibilidade = visibilidade; }
}