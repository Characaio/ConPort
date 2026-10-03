package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Usuario;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

  Optional<Usuario> findByEmailAndSenha(String Email, String Senha);

  Boolean existsByEmailAndSenha(String Email, String Senha);

  @Query(
      """
          SELECT COUNT(r)
          FROM Report r
          WHERE r.Usuario.Id = :usuarioId
      """)
  long countReportsEnviados(Long usuarioId);

  @Query(
      """
          SELECT COUNT(r)
          FROM Report r
          WHERE r.Usuario.Id = :usuarioId
          AND r.Status = :status
      """)
  long countReportsByStatus(Long usuarioId, StatusReport status);

  // ~ Cae
  Optional<Usuario> findByApelidoIgnoreCase(String Apelido);

  boolean existsByApelidoIgnoreCase(String Apelido);

  @Query(
      """
          SELECT COUNT(r)
          FROM UsuarioRelacionamento r
          WHERE r.Seguindo.Id = :usuarioId
          AND r.Status = :status
      """)
  long countSeguidores(
      @Param("usuarioId") Long usuarioId, @Param("status") StatusRelacionamento status);

  @Query(
      """
          SELECT COUNT(r)
          FROM UsuarioRelacionamento r
          WHERE r.Seguidor.Id = :usuarioId
          AND r.Status = :status
      """)
  long countSeguindo(
      @Param("usuarioId") Long usuarioId, @Param("status") StatusRelacionamento status);

  @Query(
      """
          SELECT u FROM Usuario u
          WHERE u.Id <> :usuarioId
          AND (LOWER(u.Apelido) = LOWER(:termo)
               OR LOWER(u.Nome) LIKE LOWER(CONCAT('%', :termo, '%')))
      """)
  List<Usuario> buscar(
      @Param("usuarioId") Long usuarioId, @Param("termo") String termo, Pageable pageable);
}
