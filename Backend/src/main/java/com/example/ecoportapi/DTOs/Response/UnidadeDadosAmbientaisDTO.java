package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.UnidadeDeConservacao;

/**
 * Responsabilidade: Representa todos dados ambientais pré cadastrados de uma unidade de conservação
 */
public record UnidadeDadosAmbientaisDTO(
        Double areaTotal,
        Double areaRegularizada,
        Double areaPreservada,
        Double areaMonitorada,
        Double areaBasePorCorredor,
        Integer pontosMonitorados,
        Integer pontosPrevistos,
        Integer quantCorredores,
        Integer quantEspecies,
        Integer quantEspeciesEsperadas,
        Double qualidadeAgua,
        Double qualidadeSolo,
        Double gestaoResiduos
) {
    public UnidadeDadosAmbientaisDTO(UnidadeDeConservacao unidade){
        this(
                unidade.getAreaTotal(),
                unidade.getAreaRegularizada(),
                unidade.getAreaPreservada(),
                unidade.getAreaMonitorada(),
                unidade.getAreaBasePorCorredor(),
                unidade.getPontosMonitorados(),
                unidade.getPontosPrevistos(),
                unidade.getQuantidadeCorredores(),
                unidade.getQuantidadeEspecies(),
                unidade.getQuantidadeEspeciesEsperadas(),
                unidade.getQualidadeAgua(),
                unidade.getQualidadeSolo(),
                unidade.getGestaoResiduos()
        );
    }
}
