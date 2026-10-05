package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.UsuarioSegue;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 * Quem segue quem.
 *
 * <p>Queries explícitas pelo mesmo motivo das de {@code UsuarioRepository}:
 * com o Hibernate 7 o nome derivado precisa bater exatamente com o atributo.
 */
@Repository
public interface UsuarioSegueRepository extends JpaRepository<UsuarioSegue, Long> {

  @Query("""
          SELECT r FROM UsuarioSegue r
          WHERE r.Seguidor.Id = :seguidorId AND r.Seguindo.Id = :seguindoId
      """)
  Optional<UsuarioSegue> buscar(
      @Param("seguidorId") Long seguidorId, @Param("seguindoId") Long seguindoId);

  @Query("""
          SELECT COUNT(r) > 0 FROM UsuarioSegue r
          WHERE r.Seguidor.Id = :seguidorId AND r.Seguindo.Id = :seguindoId
      """)
  boolean existe(
      @Param("seguidorId") Long seguidorId, @Param("seguindoId") Long seguindoId);

  // "Quem eu sigo": a linha traz quem está sendo seguido.
  @Query("""
          SELECT r FROM UsuarioSegue r
          JOIN FETCH r.Seguindo
          WHERE r.Seguidor.Id = :usuarioId
          ORDER BY r.Seguindo.Nome
      """)
  List<UsuarioSegue> findQuemEuSigo(@Param("usuarioId") Long usuarioId);

  // "Quem me segue": a linha traz quem está seguindo.
  @Query("""
          SELECT r FROM UsuarioSegue r
          JOIN FETCH r.Seguidor
          WHERE r.Seguindo.Id = :usuarioId
          ORDER BY r.Seguidor.Nome
      """)
  List<UsuarioSegue> findQuemMeSegue(@Param("usuarioId") Long usuarioId);

  @Query("""
          SELECT COUNT(r)
          FROM UsuarioSegue r
          WHERE r.Seguindo.Id = :usuarioId
      """)
  long countSeguidores(@Param("usuarioId") Long usuarioId);

  @Query("""
          SELECT COUNT(r)
          FROM UsuarioSegue r
          WHERE r.Seguidor.Id = :usuarioId
      """)
  long countSeguindo(@Param("usuarioId") Long usuarioId);

  /**
   * Apaga os vínculos de seguir em que a conta aparece, dos dois lados.
   *
   * <p>Os dois lados porque seguir é relação entre duas pessoas: se apagar só o
   * "quem eu sigo", o "quem me segue" continuaria apontando para um usuário que
   * não existe mais.
   */
  @Modifying
  @Query("""
        DELETE FROM UsuarioSegue s
        WHERE s.Seguidor.Id = :usuarioId OR s.Seguindo.Id = :usuarioId
    """)
  int apagarDoUsuario(@Param("usuarioId") Long usuarioId);
}
