package com.example.ecoportapi.DTOs.Request;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record UsuarioCreateDTO(
        String username,
        LocalDate dataNasc,
        String email,
        String senha,
        String estado,
        String cidade
) {
}
