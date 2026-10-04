package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Missao;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MissaoRepository extends JpaRepository<Missao, Long> {

  @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.Usuario.Id = :usuarioId
        AND r.Status = :status
    """)
  Integer countMissoesConcluidas(Long usuarioId, StatusMissao statusMissao);

  // Com o Hibernate 7 o nome derivado precisa bater com o atributo, por isso
  // as queries de missão são explícitas.
  @Query("""
        SELECT m FROM Missao m
        JOIN FETCH m.Usuario
        WHERE m.Usuario.Id = :usuarioId
        ORDER BY m.StatusMissao, m.Id
    """)
  List<Missao> listarDoUsuario(@Param("usuarioId") Long usuarioId);

  @Query("""
        SELECT COUNT(m) > 0 FROM Missao m
        WHERE m.Usuario.Id = :usuarioId
    """)
  boolean existeAlgumaDoUsuario(@Param("usuarioId") Long usuarioId);
}