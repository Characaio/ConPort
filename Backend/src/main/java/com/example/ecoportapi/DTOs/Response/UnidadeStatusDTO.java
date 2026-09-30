package com.example.ecoportapi.DTOs.Response;

/**
Responsabilidade: DTO que representa TODAS informações da undiade
 **/
public record UnidadeStatusDTO(
    UnidadeInformacoesDTO informacoes,
    UnidadeIndicadoresDTO indicadores,
    UnidadeDadosAmbientaisDTO dadosAmbientais,
    Integer quantReports
) {}
