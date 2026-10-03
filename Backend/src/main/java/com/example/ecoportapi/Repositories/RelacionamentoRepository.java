package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.UsuarioRelacionamento;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RelacionamentoRepository extends JpaRepository<UsuarioRelacionamento, Long> {

  Optional<UsuarioRelacionamento> findBySeguidorIdAndSeguindoId(Long seguidorId, Long seguindoId);

  Optional<UsuarioRelacionamento> findByIdAndSeguindoId(Long id, Long seguidorId);

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

  List<UsuarioRelacionamento> findBySeguidorIdAndStatus(
      Long seguidorId, StatusRelacionamento status);
}
