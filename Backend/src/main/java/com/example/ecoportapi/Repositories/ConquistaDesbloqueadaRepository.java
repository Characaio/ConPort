package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.ConquistaDesbloqueada;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConquistaDesbloqueadaRepository
        extends JpaRepository<ConquistaDesbloqueada, Long> {

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo, por isso
    // a query e explicita.
    @Query("""
        SELECT c
        FROM ConquistaDesbloqueada c
        WHERE c.Usuario.Id = :usuarioId
        ORDER BY c.Data ASC
    """)
    List<ConquistaDesbloqueada> listarDoUsuario(
            @Param("usuarioId") Long usuarioId
    );

    @Query("""
        SELECT COUNT(c)
        FROM ConquistaDesbloqueada c
        WHERE c.Usuario.Id = :usuarioId
          AND c.Chave = :chave
    """)
    Integer contarDoUsuarioComChave(
            @Param("usuarioId") Long usuarioId,
            @Param("chave") String chave
    );

  /** Conquistas da conta: some junto com ela, não têm sentido sem o dono. */
  @Modifying
  @Query("""
        DELETE FROM ConquistaDesbloqueada c
        WHERE c.Usuario.Id = :usuarioId
    """)
  int apagarDoUsuario(@Param("usuarioId") Long usuarioId);
}