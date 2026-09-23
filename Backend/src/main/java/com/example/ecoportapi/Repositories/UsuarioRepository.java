package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.Enums.StatusReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;


public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.usuario.id = :usuarioId
    """)
    long countReportsEnviados(Long usuarioId);

    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.usuario.id = :usuarioId
        AND r.status = :status
    """)
    long countReportsByStatus(Long usuarioId, StatusReport status);
}
