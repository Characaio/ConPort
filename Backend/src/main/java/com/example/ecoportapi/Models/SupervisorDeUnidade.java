package com.example.ecoportapi.Models;

import jakarta.persistence.*;

@Entity
public class SupervisorDeUnidade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario Usuario;

    @ManyToOne
    @JoinColumn(name = "unidade_id", nullable = false)
    private UnidadeDeConservacao Unidade;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { Usuario = usuario; }

    public UnidadeDeConservacao getUnidade() { return Unidade; }
    public void setUnidade(UnidadeDeConservacao unidade) { Unidade = unidade; }
}
