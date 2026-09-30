package com.example.ecoportapi.DTOs.Response;

/**
 * Responsabilidade: Representa todos indicadores derivados de uma unidade de conservação
 */
public record UnidadeIndicadoresDTO(
        Double integridadeTerritorial,
        Integer corredoresNecessarios,
        Double conectividadeEcologica,
        Double qualidadeAmbiental,
        Double preservacaoLocal,
        Double fiscalizacao,
        Double biodiversidade
) {}
