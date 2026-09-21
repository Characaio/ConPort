package com.example.ecoportapi.DTOs.Response;

public record UnidadeIndicadoresDerivadosDTO(
        Double IntegridadeTerritorial,
        Integer CorredoresNecessarios,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        Double Fiscalizacao,
        Double Biodiversidade
) {}
