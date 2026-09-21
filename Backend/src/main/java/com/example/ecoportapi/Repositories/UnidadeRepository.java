package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UnidadeRepository extends JpaRepository<UnidadeDeConservacao,Long> {

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.Response.UnidadeStatusPrincipalBaseDTO(
        u.Id,
        u.Nome,
        u.Telefone,
        u.TipoDeUnidade,
        u.HoraDeAbertura,
        u.HoraDeFechamento
    )
    FROM UnidadeDeConservacao u
    WHERE u.Id = :unidadeId
    """)
    public UnidadeStatusPrincipalBaseDTO PegarStatusPrincipal(@Param("unidadeId") Long unidadeId);

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.Response.UnidadeStatusGeralBaseDTO(
                u.Id,u.Nome,u.Localizacao,u.Bioma,u.Telefone,u.HoraDeAbertura,u.HoraDeFechamento,
                u.TipoDeUnidade,u.AreaTotal,u.AreaRegularizada,u.AreaPreservada,
                u.AreaMonitorada,u.AreaBasePorCorredor, u.PontosMonitorados, u.PontosPrevistos,
                u.QuantidadeCorredores, u.QuantEspecies,u.QuantEspeciesEsperadas,
                u.QualidadeAgua,u.QualidadeSolo,u.GestaoResiduos
        )
        FROM UnidadeDeConservacao u
        WHERE u.Id = :unidadeId
    """)
    public UnidadeStatusGeralBaseDTO PegarStatusGeral(@Param("unidadeId") Long unidadeId);


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
            r.Local,
            r.DataDoOcorrido,
            r.Status
            ) FROM Report r
            WHERE r.Unidade.Id = :unidadeId
    """)
    public List<ReportResumidoDTO> PegarReportsDaUnidade(@Param("unidadeId") Long unidadeId);
}
