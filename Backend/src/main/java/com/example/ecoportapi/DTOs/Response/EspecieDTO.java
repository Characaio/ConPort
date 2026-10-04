package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.TipoEspecie;
import com.example.ecoportapi.Models.Especie;

/**
 * Especie como aparece no card da tela de ecossistema.
 */
public record EspecieDTO(
        Long Id,
        String Nome,
        String NomeCientifico,
        String Descricao,
        String Imagem,
        TipoEspecie Tipo
) {
    public EspecieDTO(Especie especie) {
        this(
                especie.getId(),
                especie.getNome(),
                especie.getNomeCientifico(),
                especie.getDescricao(),
                especie.getImagem(),
                especie.getTipo()
        );
    }
}