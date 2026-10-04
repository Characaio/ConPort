package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Especie;
import com.example.ecoportapi.Models.Enums.TipoEspecie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EspecieRepository extends JpaRepository<Especie, Long> {

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo, por isso
    // as queries de especie sao explicitas.
    @Query("""
        SELECT e
        FROM Especie e
        WHERE e.Unidade.Id = :unidadeId
          AND e.Tipo = :tipo
        ORDER BY e.Nome ASC
    """)
    List<Especie> listarDaUnidade(
            @Param("unidadeId") Long unidadeId,
            @Param("tipo") TipoEspecie tipo
    );

    @Query("""
        SELECT COUNT(e)
        FROM Especie e
        WHERE e.Unidade.Id = :unidadeId
    """)
    Integer contarDaUnidade(@Param("unidadeId") Long unidadeId);
}