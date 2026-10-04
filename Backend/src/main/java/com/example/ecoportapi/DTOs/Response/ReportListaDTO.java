package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.ReportPrioridade;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Report como aparece na lista: só o que o card mostra.
 *
 * O supervisor e opcional, porque um report recem-registrado ainda nao foi
 * analisado por ninguem.
 */
public record ReportListaDTO(
        Long Id,
        Long UnidadeId,
        String UnidadeNome,
        Long UsuarioId,
        String UsuarioNome,
        TipoDeIncidente Tipo,
        StatusReport Status,
        ReportPrioridade Prioridade,
        LocalDateTime DataDoOcorrido,
        String Descricao,
        Double Latitude,
        Double Longitude,
        Integer QuantidadeAnexos,
        String SupervisorNome,
        LocalDateTime DataDaAnalise,
        String MotivoDaNegacao
) {
    public ReportListaDTO(Report report){
        this(
                report.getId(),
                report.getUnidade().getId(),
                report.getUnidade().getNome(),
                report.getUsuario().getId(),
                report.getUsuario().getNome(),
                report.getTipo(),
                report.getStatus(),
                // A tela de detalhe desenha a barra de urgencia com isso.
                report.getPrioridade(),
                report.getDataDoOcorrido(),
                report.getDescricao(),
                report.getLatitude(),
                report.getLongitude(),
                contarAnexos(report),
                report.getSupervisor() != null
                        ? report.getSupervisor().getUsuario().getNome()
                        : null,
                report.getDataDaAnalisa(),
                report.getMotivoDaNegacao()
        );
    }

    private static int contarAnexos(Report report){
        List<String> imagens = report.getImagensAnexadas();
        return imagens == null ? 0 : imagens.size();
    }
}