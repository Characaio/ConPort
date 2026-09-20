package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusGeralDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusPrincipalDTO;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UnidadeRepository extends JpaRepository<UnidadeDeConservacao,Long> {

    @Query("""
    SELECT new com.example.ecoportapi.DTOs.UnidadeStatusPrincipalDTO(
        u.IntegridadeTerritorial,
        u.ConectividadeEcologica,
        u.QualidadeAmbiental,
        u.PreservacaoLocal,
        u.Fiscalizacao,
        u.Biodiversidade
    )
    FROM UnidadeDeConservacao u
    WHERE u.Id = :unidadeId
    """)
    public UnidadeStatusPrincipalDTO PegarStatusPrincipal(@Param("unidadeId") Long unidadeId);

    @Query("""
    SELECT new com.exmaple.ecoportapi.DTOs.UnidadeStatusGeralDTO(
                u.TipoDeUnidade,u.AreaTotal,u.AreaRegularizada,u.AreaPreservada,
                u.AreaMonitorada,u.QuantCorredores,u.QuantEspecies,u.QuantEspeciesEsperadas,
                u.QualidadeAgua,u.QualidadeSolo,u.GestaoResiduos,
        
                u.IntegridadeTerritorial,u.ConectividadeEcologica,
                u.QualidadeAmbiental,u.PreservacaoLocal,
                u.Fiscalizacao,u.Biodiversidade
        )   
        FROM UnidadeDeConservacao u
        WHERE u.Id = :unidadeId
    """)
    public UnidadeStatusGeralDTO PegarStatusGeral(@Param("unidadeId") Long unidadeId);

    @Query("""
        SELECT new com.example.ecoportapi.DTOs.ReportResumidoDTO(
            r.Id,
            r.Tipo,
            r.Status,
            r.DataDoOcorrido,
            r.Local,
            r.Descricao,
            r.ImagensRelacionadas,
            r.Usuario.Nome,
            s.Nome,
            r.DataDaAnalise
            ) FROM Report r
            LEFT JOIN r.Supervisor s
            WHERE r.Unidade.Id = :unidadeId
    """)
    public List<ReportResumidoDTO> PegarReportsDaUnidade(@Param("unidadeId") Long unidadeId);
}
