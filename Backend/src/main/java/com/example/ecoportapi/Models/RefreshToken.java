package com.example.ecoportapi.Models;

import jakarta.persistence.*;

import java.time.Instant;

@Entity
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(nullable = false, unique = true)
    private String TokenHash;

    @ManyToOne
    @JoinColumn(name = "UsuarioId", nullable = false)
    private Usuario Usuario;

    @Column(nullable = false)
    private Instant ExpiraEm;

    @Column(nullable = false)
    private boolean Revogado;

    @Column(nullable = false)
    private Instant CriadoEm;

    public Long getId() { return Id; }
    public void setId(Long id) { this.Id = id; }

    public String getTokenHash() { return TokenHash; }
    public void setTokenHash(String tokenHash) { this.TokenHash = tokenHash; }

    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { this.Usuario = usuario; }

    public Instant getExpiraEm() { return ExpiraEm; }
    public void setExpiraEm(Instant expiraEm) {this.ExpiraEm = expiraEm; }

    public boolean isRevogado() { return Revogado; }
    public void setRevogado(boolean revogado) { this.Revogado = revogado; }

    public Instant getCriadoEm() { return CriadoEm; }
    public void setCriadoEm(Instant criadoEm) { this.CriadoEm = criadoEm; }
}
