package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReportRepository extends JpaRepository<Report,Long> {

    List<Report> findByUnidadeIdAndUsuarioId(Long UnidadeId,Long UsuarioId);

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.Response.ReportResumidoDTO(
        r.Id,
        r.Tipo,
        r.DataDoOcorrido,
        r.Prioridade,
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
