package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.ReportPrioridade;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;

import java.time.LocalDateTime;
import java.util.List;

public record ReportExpandidoDTO(
        Long Id,
        TipoDeIncidente Tipo,
        StatusReport Status,
        LocalDateTime DataDoOcorrido,
        String Descricao,
        ReportPrioridade Prioridade,
        List<String> ImagensAnexadas,
        String UsuarioNome,
        String UnidadeNome,
        String SupervisorNome,
        LocalDateTime DataDaAnalise
) {
    public ReportExpandidoDTO(Report report) {
        this(
                report.getId(),
                report.getTipo(),
                report.getStatus(),
                report.getDataDoOcorrido(),
                report.getDescricao(),
                report.getPrioridade(),
                report.getImagensAnexadas(),
                report.getUsuario().getNome(),
                report.getUnidade().getNome(),
                report.getSupervisor() != null
                        ? report.getSupervisor().getUsuario().getNome()
                        : null,
                report.getDataDaAnalisa()
        );


    }
}
