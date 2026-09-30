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

    @Query("""
        SELECT r
        FROM Report r
        WHERE r.Unidade.Id = :unidadeId
          AND r.Usuario.Id = :usuarioId
    """)
    List<Report> BuscarReportsDoUsuarioNaUnidade(
            @Param("unidadeId") Long unidadeId,
            @Param("usuarioId") Long usuarioId
    );

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

    //No futuro, mudar o status para ser um parametro, isso permite uma analise mais detalhada
    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Unidade.Id = :unidadeId
    """)
    public Integer PegarQuantDeReports(@Param("unidadeId") Long unidadeId);

    @Query("""
        SELECT new com.example.ecoportapi.DTOs.Response.ReportResumidoDTO(
            r.Id,
            r.Tipo,
            r.DataDoOcorrido,
            r.Prioridade,
            r.Status
            ) FROM Report r
            WHERE r.Unidade.Id = :unidadeId
    """)
    public List<ReportResumidoDTO> PegarReportsDaUnidade(@Param("unidadeId") Long unidadeId);
}
