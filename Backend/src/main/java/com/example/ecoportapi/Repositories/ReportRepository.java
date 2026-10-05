package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

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

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo, por isso
    // as queries de report sao explicitas.
    @Query("""
        SELECT r
        FROM Report r
        JOIN FETCH r.Usuario
        JOIN FETCH r.Unidade
        WHERE r.Unidade.Id = :unidadeId
        ORDER BY r.DataDoOcorrido DESC
    """)
    List<Report> listarDaUnidade(@Param("unidadeId") Long unidadeId);

    @Query("""
        SELECT r
        FROM Report r
        JOIN FETCH r.Usuario
        JOIN FETCH r.Unidade
        WHERE r.Usuario.Id = :usuarioId
        ORDER BY r.DataDoOcorrido DESC
    """)
    List<Report> listarDoUsuario(@Param("usuarioId") Long usuarioId);

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

  /**
   * Apaga os reports da conta. Sem isso a exclusão da conta batia em violação
   * de chave estrangeira: o report aponta para o usuário e o banco não deixa.
   */
  @Modifying
  @Query("""
        DELETE FROM Report r
        WHERE r.Usuario.Id = :usuarioId
    """)
  int apagarDoUsuario(@Param("usuarioId") Long usuarioId);
}