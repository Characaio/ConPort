package com.example.ecoportapi.DTOs.Response;

public record UnidadeStatusGeralDTO(
        String TipoDeUnidade,

        Double AreaTotal,
        Double AreaRegularizada,
        Double AreaPreservada,
        Double AreaMonitorada,
        Integer QuantCorredores,
        Integer QuantEspecies,
        Integer QuantEspeciesEsperadas,
        Double QualidadeAgua,
        Double QualidadeSolo,
        Double GestaoResiduos,

        Double IntegridadeTerritorial,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        String Fiscalizacao,
        String Biodiversidade
) {}
