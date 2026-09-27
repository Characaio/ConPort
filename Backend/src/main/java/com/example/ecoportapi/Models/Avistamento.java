package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.AvistamentoCerteza;
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

    @Column(name = "Local",nullable = false)
    private String Local;

    @Enumerated(EnumType.STRING)
    @Column(name = "Certeza", nullable = false)
    private AvistamentoCerteza Certeza;

    @Column(name = "EspecieAvistada", nullable = false)
    private String EspecieAvistada;

    @Column(name = "ImagenAnexada", nullable = false)
    private String ImagemAnexada;



    public Long getId() { return Id; }
    public void setId(Long id) { Id = id; }

    public LocalDateTime getHoraDoAvistamento() { return HoraDoAvistamento; }
    public void setHoraDoAvistamento(LocalDateTime horaDoAvistamento) { HoraDoAvistamento = horaDoAvistamento; }

    public String getLocal() { return Local; }
    public void setLocal(String local) { Local = local; }

    public AvistamentoCerteza getCerteza() { return Certeza; }
    public void setCerteza(AvistamentoCerteza certeza) { Certeza = certeza; }

    public String getEspecieAvistada() { return EspecieAvistada; }
    public void setEspecieAvistada(String especieAvistada) { EspecieAvistada = especieAvistada; }

    public String getImagemAnexada() { return ImagemAnexada; }
    public void setImagemAnexada(String imagemAnexada) { ImagemAnexada = imagemAnexada; }





}
