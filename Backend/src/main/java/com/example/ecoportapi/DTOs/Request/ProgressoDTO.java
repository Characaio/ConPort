package com.example.ecoportapi.DTOs.Request;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Corpo de {@code POST /missoes/{id}/progresso}.
 *
 * O frontend envia {@code progresso} em minúscula, por isso o alias.
 */
public record ProgressoDTO(
        @JsonProperty("progresso")
        @JsonAlias({"Progresso"})
        Integer Progresso
) { }