package com.example.ecoportapi.DTOs.Response;

public record ReportResumidoDTO(
    Long Id,
    String Tipo,
    String Local,
    String DataDoOcorrido,
    String Status

) {}
