package com.example.ecoportapi.DTOs.Request;

public record TraducaoRequestDTO(
        String texto,
        String linguaOrigem,
        String linguaAlvo,
        String tipoTexto
) {}
