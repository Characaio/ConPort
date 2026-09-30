package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import com.example.ecoportapi.Models.Report;
import com.example.ecoportapi.Models.UnidadeDeConservacao;

import java.time.LocalTime;

/**
 * Representa toda informação não ambiental da unidade de conservação
 */
public record UnidadeInformacoesDTO(
        Long id,
        String nome,
        String telefone,
        TipoDeUnidade tipoDeUnidade,
        LocalTime horaDeAbertura,
        LocalTime horaDeFechamento,
        Double Latitude,
        Double Longitude
) {
    public UnidadeInformacoesDTO (UnidadeDeConservacao unidade){
        this(
                unidade.getId(),
                unidade.getNome(),
                unidade.getTelefone(),
                unidade.getTipoDeUnidade(),
                unidade.getHoraAbertura(),
                unidade.getHoraFechamento(),
                unidade.getLatitude(),
                unidade.getLongitude()
        );
    }
}
