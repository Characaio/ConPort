package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.PerigoDeExtincao;
import com.example.ecoportapi.Models.Enums.ReinoBioGeografico;
import com.example.ecoportapi.Models.Enums.TendenciaPopulacional;

import java.util.List;

public record EspecieRedListInfoDTO(
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
}
