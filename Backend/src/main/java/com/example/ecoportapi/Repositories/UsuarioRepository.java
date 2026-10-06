package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.Enums.StatusReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByEmailAndSenha(String Email, String Senha);
    Boolean existsByEmailAndSenha(String Email, String Senha);
    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Usuario.Id = :usuarioId
    """)
    long countReportsEnviados(Long usuarioId);

    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Usuario.Id = :usuarioId
        AND r.Status = :status
    """)
    long countReportsByStatus(Long usuarioId, StatusReport status);
}
