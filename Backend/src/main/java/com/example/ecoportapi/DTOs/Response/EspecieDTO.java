package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Especie;
import com.example.ecoportapi.Models.Enums.PerigoDeExtincao;
import com.example.ecoportapi.Models.Enums.ReinoBioGeografico;
import com.example.ecoportapi.Models.Enums.TendenciaPopulacional;

import java.util.List;

public record EspecieDTO(
        Long id,
        String nomeComum,
        String descricaoExpandida,
        String descricaoResumida,
        String imagemURLThumb,
        String imagemURLOriginal,

        String autorDaImagem,
        String licenca,
        String termosDeUso,

        String nomeCientifico,
        String reino,
        String filo,
        String classe,
        String ordem,
        String familia,
        String genus,
        String especie,
        List<String> habitats,
        List<ReinoBioGeografico> reinosBioGeograficos,
        TendenciaPopulacional tendenciaPopulacional,
        PerigoDeExtincao perigoDeExtincao
) {

    public EspecieDTO (Especie especie) {
        this(
                especie.getId(),
                especie.getNomeComum(),
                especie.getDescricaoExpandida(),
                especie.getDescricaoResumida(),
                especie.getImagemURLThumb(),
                especie.getImagemURLOriginal(),

                especie.getAutorDaImagem(),
                especie.getLicenca(),
                especie.getTermosDeUso(),

                especie.getNomeCientifico(),
                especie.getReino(),
                especie.getFilo(),
                especie.getClasse(),
                especie.getOrdem(),
                especie.getFamilia(),
                especie.getGenus(),
                especie.getEspecie(),
                especie.getHabitats(),
                especie.getReinosBioGeograficos(),
                especie.getTendenciaPopulacional(),
                especie.getPerigoDeExtincao()
        );
    }
}