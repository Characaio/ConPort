package com.example.ecoportapi.Models;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Uma conquista já desbloqueada por um usuário.
 *
 * A chave é a string que o app manda (report_enviado, avistamento_enviado…),
 * guardada como texto para o backend não depender do português dos títulos:
 * se o app renomear um título, o dado antigo continua legível.
 */
@Entity
@Table(name = "ConquistaDesbloqueada")
public class ConquistaDesbloqueada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Usuario", nullable = false)
    private Usuario Usuario;

    @Column(name = "Chave", nullable = false, length = 60)
    private String Chave;

    @Column(name = "Data", nullable = false)
    private LocalDateTime Data;

    public ConquistaDesbloqueada() {
    }

    public ConquistaDesbloqueada(Usuario usuario, String chave) {
        this.Usuario = usuario;
        this.Chave = chave;
        this.Data = LocalDateTime.now();
    }

    public Long getId() {
        return Id;
    }

    public Usuario getUsuario() {
        return Usuario;
    }

    public String getChave() {
        return Chave;
    }

    public LocalDateTime getData() {
        return Data;
    }
}