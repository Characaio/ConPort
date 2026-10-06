package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.LocalizacaoOrigem;

public record AvistamentoCreateDTO(
    Double Longitude,
    Double Latitude,
    LocalizacaoOrigem Origem,
    Long UnidadeId
) {}
