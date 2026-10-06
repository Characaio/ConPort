package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.UnidadeEspecie;

public record UnidadeEspecieDTO(
        Long id,
        Long unidadeId,
        Long especieId
) {
    public UnidadeEspecieDTO(UnidadeEspecie unidadeEspecie){
        this(
                unidadeEspecie.getId(),
                unidadeEspecie.getUnidade().getId(),
                unidadeEspecie.getEspecie().getId()
        );
    }
}
