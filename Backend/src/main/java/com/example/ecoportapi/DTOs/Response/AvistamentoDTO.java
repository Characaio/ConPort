package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Avistamento;
import com.example.ecoportapi.Models.Enums.AvistamentoCerteza;

import java.time.LocalDateTime;

public record AvistamentoDTO(
    Long Id,
    LocalDateTime HorarioDoAvistamento,
    Double Longitude,
    Double Latitude,
    Double Certeza,
    String EspecieAvistada,
    String ImagemAnexada,
    String UsuarioNome,
    String UnidadeNome
) {
    public AvistamentoDTO(Avistamento avistamento){
        this(
                avistamento.getId(),
                avistamento.getHoraDoAvistamento(),
                avistamento.getLongitude(),
                avistamento.getLatitude(),
                avistamento.getCerteza(),
                avistamento.getEspecieAvistada(),
                avistamento.getImagemAnexada(),
                avistamento.getUsuario().getNome(),
                avistamento.getUnidade().getNome()
        );
    }
}
