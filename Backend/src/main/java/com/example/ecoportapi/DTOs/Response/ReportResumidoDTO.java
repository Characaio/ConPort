package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.ReportPrioridade;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;

import java.time.LocalDateTime;

public record ReportResumidoDTO(
    Long Id,
    TipoDeIncidente Tipo,
    LocalDateTime DataDoOcorrido,
    ReportPrioridade Prioridade,
    StatusReport Status,
    String motivoNegacao,
    String supervisorNome

) {
    public ReportResumidoDTO(Report report){
        this(
                report.getId(),
                report.getTipo(),
                report.getDataDoOcorrido(),
                report.getPrioridade(),
                report.getStatus(),
                report.getMotivoDaNegacao(),
                // Um report ainda não analisado não tem supervisor.
                report.getSupervisor() != null
                        ? report.getSupervisor().getUsuario().getNome()
                        : null
        );
    }
}