package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;

import java.time.LocalDateTime;

public record ReportResumidoDTO(
    Long Id,
    TipoDeIncidente Tipo,
    String Local,
    LocalDateTime DataDoOcorrido,
    StatusReport Status

) {}
