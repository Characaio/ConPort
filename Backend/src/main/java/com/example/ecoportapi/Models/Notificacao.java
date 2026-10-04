package com.example.ecoportapi.Models;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Uma notificação de um usuário.
 *
 * O título e o texto são gravados como vieram do app: quem decide o que é
 * notificação é o frontend (conquista liberada, missão concluída, aviso da
 * unidade…), e o backend só guarda e entrega. Assim o backend não precisa
 * conhecer cada regra do app — o mesmo raciocínio das chaves em
 * ConquistaDesbloqueada.
 *
 * `Lida` fica no registro (e não só no app) para que o sino do topo da tela
 * continue marcando não lida depois de fechar o app.
 */
@Entity
@Table(name = "Notificacao")
public class Notificacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long Id;

    @ManyToOne
    @JoinColumn(name = "Usuario", nullable = false)
    private Usuario Usuario;

    @Column(name = "Titulo", nullable = false)
    private String Titulo;

    @Column(name = "Texto", nullable = false, length = 1000)
    private String Texto;

    @Column(name = "Data", nullable = false)
    private LocalDateTime Data;

    @Column(name = "Lida", nullable = false)
    private Boolean Lida;

    public Notificacao() {
    }

    public Notificacao(Usuario usuario, String titulo, String texto) {
        this.Usuario = usuario;
        this.Titulo = titulo;
        this.Texto = texto;
        this.Data = LocalDateTime.now();
        this.Lida = false;
    }

    @PrePersist
    void prePersist() {
        // Quem cria pelo app já passa com a data; o default cobre o resto.
        if (Data == null) {
            Data = LocalDateTime.now();
        }

        if (Lida == null) {
            Lida = false;
        }
    }

    public Long getId() {
        return Id;
    }

    public Usuario getUsuario() {
        return Usuario;
    }

    public void setUsuario(Usuario usuario) {
        Usuario = usuario;
    }

    public String getTitulo() {
        return Titulo;
    }

    public void setTitulo(String titulo) {
        Titulo = titulo;
    }

    public String getTexto() {
        return Texto;
    }

    public void setTexto(String texto) {
        Texto = texto;
    }

    public LocalDateTime getData() {
        return Data;
    }

    public void setData(LocalDateTime data) {
        Data = data;
    }

    public Boolean getLida() {
        return Lida;
    }

    public void setLida(Boolean lida) {
        Lida = lida;
    }
}
