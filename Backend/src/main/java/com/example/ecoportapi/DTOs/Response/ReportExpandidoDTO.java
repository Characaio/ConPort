package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Report;

import java.util.List;

public record ReportExpandidoDTO(
        Long Id,
        String Tipo,
        String Status,
        String DataDoOcorrido,
        String Local,
        String Descricao,
        List<String> ImagensNomes,
        String UsuarioNome,
        String UnidadeNome,
        String SupervisorNome,
        String DataDaAnalise
) {
    public ReportExpandidoDTO(Report report) {
        this(
                report.getId(),
                report.getTipo().name(),
                report.getStatus().name(),
                report.getDataDoOcorrido().toString(),
                report.getLocal(),
                report.getDescricao(),
                report.getImagensRelacionadas(),
                report.getUsuario().getNome(),
                report.getUnidade().getNome(),
                report.getSupervisor().getUsuario().getNome(),
                report.getDataDaAnalisa().toString()
        );


    }
}
