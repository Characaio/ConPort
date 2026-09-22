package com.example.ecoportapi.DTOs.Request;

import java.util.List;

public record ReportCreateDTO(
    String Tipo,
    String Descricao,
    List<String> ImagensAnexadas,
    String DataDoOcorrido,
    Long UsuarioId
) {}
