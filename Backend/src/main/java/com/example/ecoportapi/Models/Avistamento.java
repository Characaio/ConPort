package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.AvistamentoCerteza;
import jakarta.persistence.*;

import java.lang.classfile.constantpool.DoubleEntry;
import java.security.PublicKey;
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



    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public LocalDateTime getHoraDoAvistamento() { return HoraDoAvistamento; }
    public void setHoraDoAvistamento(LocalDateTime horaDoAvistamento) { HoraDoAvistamento = horaDoAvistamento; }

    public Double setLongitude(){ return Longitude; }
    public void setLongitude(Double longitude) {Longitude = longitude; }

    public Double setLatitude(){ return Latitude; }
    public void setLatitude(Double latitude) {Latitude = latitude; }

    public Double getCerteza() { return Certeza; }
    public void setCerteza(Double certeza) { Certeza = certeza; }

    public String getEspecieAvistada() { return EspecieAvistada; }
    public void setEspecieAvistada(String especieAvistada) { EspecieAvistada = especieAvistada; }

    public String getImagemAnexada() { return ImagemAnexada; }
    public void setImagemAnexada(String imagemAnexada) { ImagemAnexada = imagemAnexada; }





}
