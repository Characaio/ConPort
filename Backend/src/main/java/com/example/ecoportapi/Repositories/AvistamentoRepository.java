package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Avistamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvistamentoRepository extends JpaRepository<Avistamento,Long> {

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo.
    @Query("""
        SELECT a
        FROM Avistamento a
        WHERE a.Usuario.Id = :usuarioId
    """)
    List<Avistamento> listarDoUsuario(@Param("usuarioId") Long usuarioId);

    @Query("""
        SELECT a
        FROM Avistamento a
        WHERE a.Unidade.Id = :unidadeId
    """)
    List<Avistamento> listarDaUnidade(@Param("unidadeId") Long unidadeId);
}