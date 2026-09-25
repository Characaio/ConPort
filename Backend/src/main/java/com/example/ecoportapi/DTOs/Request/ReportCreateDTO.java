package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.ReportPrioridade;

import java.util.List;

public record ReportCreateDTO(
    String Tipo,
    String Descricao,
    ReportPrioridade Prioridade,
    List<String> ImagensAnexadas,
    String DataDoOcorrido,
    Long UsuarioId
) {}
