package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.LocalizacaoOrigem;

public record LocalizacaoDTO(
        Double Longitude,
        Double Latitude,
        LocalizacaoOrigem Origem
) {}
