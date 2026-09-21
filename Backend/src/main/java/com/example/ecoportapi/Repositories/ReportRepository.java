package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report,Long> {

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO(
        r.Id,
        r.Tipo,
        r.Status,
        r.DataDoOcorrido,
        r.Local,
        r.Descricao,
        r.ImagensNomes,
        r.Usuario.Nome,
        r.Unidade.Nome,
        s.Usuario.Nome,
        r.DataDaAnalise
        ) FROM Report r
        LEFT JOIN r.Supervisor s
        WHERE r.Id = :reportId
    """)
    public ReportExpandidoDTO PegarReportCompleto(@Param("reportId") Long reportId);

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.Response.ReportResumidoDTO(
        r.Id,
        r.Tipo,
        r.Local,
        r.DataDoOcorrido,
        r.Status
        ) FROM Report r
        WHERE r.Id = :reportId
            
    """)
    public ReportResumidoDTO PegarReportResumido(@Param("reportId") Long reportId);


    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Unidade.Id = :unidadeId
          AND r.Status IN :status
    """)
    Integer PegarReportsConfirmados(
            @Param("unidadeId") Long unidadeId,
            @Param("status") List<StatusReport> status
    );

    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Unidade.Id = :unidadeId
          AND r.Status = :status
    """)
    Integer PegarReportsTratados(
            @Param("unidadeId") Long unidadeId,
            @Param("status") StatusReport status
    );
}
