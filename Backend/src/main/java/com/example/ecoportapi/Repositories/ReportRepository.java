package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.Models.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReportRepository extends JpaRepository<Report,Long> {

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.ReportExpandidoDTO(
        r.Id,
        r.Tipo,
        r.Status,
        r.DataDoOcorrido,
        r.Local,
        r.Descricao,
        r.ImagensNomes,
        r.Usuario.Nome,
        s.Nome,
        r.DataDaAnalise
        ) FROM report r
        LEFT JOIN r.Supervisor s
        WHERE r.Unidade.Id = :unidadeId
    """)
    public ReportExpandidoDTO PegarReportCompleto(@Param("unidadeId") Long unidadeId);
}
