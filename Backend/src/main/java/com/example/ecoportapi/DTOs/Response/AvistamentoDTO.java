package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Avistamento;
import com.example.ecoportapi.Models.Enums.AvistamentoCerteza;

import java.time.LocalDateTime;

public record AvistamentoDTO(
    Long Id,
    LocalDateTime HorarioDoAvistamento,
    String Local,
    AvistamentoCerteza Certeza,
    String EspecieAvistada,
    String ImagemAnexada
) {
    public AvistamentoDTO(Avistamento avistamento){
        this(
                avistamento.getId(),
                avistamento.getHoraDoAvistamento(),
                avistamento.getLocal(),
                avistamento.getCerteza(),
                avistamento.getEspecieAvistada(),
                avistamento.getImagemAnexada()
        );
    }
}
