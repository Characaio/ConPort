package com.example.ecoportapi.Models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Avistamento")
public class Avistamento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @Column(name = "HoraDoAvistamento", nullable = false)
    private LocalDateTime HoraDoAvistamento;

    @Column(name = "Longitude", nullable = true)
    private Double Longitude;

    @Column(name = "Latitude", nullable = true)
    private Double Latitude;

    @Column(name = "Certeza", nullable = false)
    private Double Certeza;

    @Column(name = "EspecieAvistada", nullable = false)
    private String EspecieAvistada;

    @Column(name = "ImagenAnexada", nullable = false)
    private String ImagemAnexada;

    @ManyToOne
    @JoinColumn(name = "Usuario", nullable = false)
    private Usuario Usuario;

    @ManyToOne
    @JoinColumn(name = "Unidade", nullable = false)
    private UnidadeDeConservacao Unidade;

    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public LocalDateTime getHoraDoAvistamento() { return HoraDoAvistamento; }
    public void setHoraDoAvistamento(LocalDateTime horaDoAvistamento) { HoraDoAvistamento = horaDoAvistamento; }

    public Double getLongitude(){ return Longitude; }
    public void setLongitude(Double longitude) {Longitude = longitude; }

    public Double getLatitude(){ return Latitude; }
    public void setLatitude(Double latitude) {Latitude = latitude; }

    public Double getCerteza() { return Certeza; }
    public void setCerteza(Double certeza) { Certeza = certeza; }

    public String getEspecieAvistada() { return EspecieAvistada; }
    public void setEspecieAvistada(String especieAvistada) { EspecieAvistada = especieAvistada; }

    public String getImagemAnexada() { return ImagemAnexada; }
    public void setImagemAnexada(String imagemAnexada) { ImagemAnexada = imagemAnexada; }

    public UnidadeDeConservacao getUnidade() { return Unidade; }
    public void setUnidade(UnidadeDeConservacao unidade) { this.Unidade = unidade; }

    public Usuario getUsuario() { return Usuario; }
    public void setUsuario(Usuario usuario) { this.Usuario = usuario; }





}
