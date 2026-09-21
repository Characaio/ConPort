package com.example.ecoportapi.DTOs.Response;

public record IndicadoresDerivadosDTO(
        Double IntegridadeTerritorial,
        Integer CorredoresNecessarios,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        Double Fiscalizacao,
        Double Biodiversidade
) {}
