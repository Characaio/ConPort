package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.UsuarioRelacionamento;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RelacionamentoRepository extends JpaRepository<UsuarioRelacionamento, Long> {

  // Queries explicitas pelo mesmo motivo das de UsuarioRepository: com o
  // Hibernate 7 o nome derivado precisa bater exatamente com o atributo.
  @Query("""
          SELECT r FROM UsuarioRelacionamento r
          WHERE r.Seguidor.Id = :seguidorId AND r.Seguindo.Id = :seguindoId
      """)
  Optional<UsuarioRelacionamento> buscar(  @Param("seguidorId") Long seguidorId,
      @Param("seguindoId") Long seguindoId);

  /**
   * Amizade aprovada em qualquer dos dois sentidos: aceitar cria as duas
   * linhas, então perguntar "são amigos?" precisa olhar as duas.
   */
  @Query("""
          SELECT COUNT(r) > 0 FROM UsuarioRelacionamento r
          WHERE r.Status = :status
          AND ((r.Seguidor.Id = :a AND r.Seguindo.Id = :b)
               OR (r.Seguidor.Id = :b AND r.Seguindo.Id = :a))
      """)
  boolean existeAmizade(
      @Param("a") Long a, @Param("b") Long b, @Param("status") StatusRelacionamento status);

  @Query("""
          SELECT r FROM UsuarioRelacionamento r
          WHERE r.Id = :id AND r.Seguindo.Id = :seguindoId
      """)
  Optional<UsuarioRelacionamento> buscarRecebida(  @Param("id") Long id,
      @Param("seguindoId") Long seguindoId);

  @Query(
      """
          SELECT r FROM UsuarioRelacionamento r
          JOIN FETCH r.Seguindo
          WHERE r.Seguindo.Id = :usuarioId
          AND r.Status = :status
          ORDER BY r.DataCriacao DESC
      """)
  List<UsuarioRelacionamento> findComStatusRecebidas(
      @Param("usuarioId") Long usuarioId, @Param("status") StatusRelacionamento status);

  @Query(
      """
          SELECT r FROM UsuarioRelacionamento r
          JOIN FETCH r.Seguindo
          WHERE r.Seguidor.Id = :usuarioId
          AND r.Status = :status
          ORDER BY r.Seguindo.Nome
      """)
  List<UsuarioRelacionamento> findComStatus(
      @Param("usuarioId") Long usuarioId, @Param("status") StatusRelacionamento status);

  /**
   * Apaga as relações de amizade/solicitação em que a conta aparece, nos dois
   * lados — quem enviou e quem recebeu, pelo mesmo motivo do
   * {@link UsuarioSegueRepository}.
   */
  @Modifying
  @Query("""
        DELETE FROM UsuarioRelacionamento r
        WHERE r.Seguidor.Id = :usuarioId OR r.Seguindo.Id = :usuarioId
    """)
  int apagarDoUsuario(@Param("usuarioId") Long usuarioId);

}
