package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.Enums.StatusReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @Query("SELECT u FROM Usuario u WHERE u.Email = :Email")
    Optional<Usuario> findByEmail(@Param("Email") String email);
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
