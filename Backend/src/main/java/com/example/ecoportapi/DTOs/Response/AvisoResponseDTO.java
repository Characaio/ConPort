package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Aviso;
import org.jspecify.annotations.NonNull;

import java.time.LocalDateTime;

public record AvisoResponseDTO(
        Long id,
        String Titutlo,
        String Descricao,
        LocalDateTime HorarioDoAviso
) {
    public AvisoResponseDTO(@NonNull Aviso aviso){
        this(
                aviso.getId(),
                aviso.getTitulo(),
                aviso.getDescricao(),
                aviso.getHorarioDoAviso()
        );
    }
}
