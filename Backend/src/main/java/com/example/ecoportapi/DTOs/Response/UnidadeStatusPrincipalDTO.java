package com.example.ecoportapi.DTOs.Response;


public record UnidadeStatusPrincipalDTO(
        Double IntegridadeTerritorial,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        String Fiscalizacao,
        String Biodiversidade
) {}
