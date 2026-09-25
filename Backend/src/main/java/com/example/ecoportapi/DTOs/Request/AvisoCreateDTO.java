package com.example.ecoportapi.DTOs.Request;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record AvisoCreateDTO(
        String Titulo,
        String Conteudo
) {
}
