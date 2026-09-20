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
    public ReportExpandidoDTO(Report report){
        this.Id = report.getId();
        this.Tipo = report.getTipo().name();
        this.Status = report.getStatus().name();
        this.DataDoOcorrido = report.getDataDoOcorrido().toString();
        this.Local = report.getLocal();
        this.Descricao = report.getDescricao();
        this.ImagensNomes = report.getImagensRelacionadas();
        this.UsuarioNome = report.getUsuario().getNome();
        this.UnidadeNome = report.getUnidade().getNome();
        this.SupervisorNome = report.getSupervisor().getUsuario().getNome();
        this.DataDaAnalise = report.getDataDaAnalisa().toString();


    }
}
