package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Aviso;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvisoRepository extends JpaRepository<Aviso,Long> {

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo: aqui
    // findByUnidadeId era lido como a propriedade "UnidadeId", que nao existe,
    // e a consulta quebrava com "Binding property is null".
    @Query("""
        SELECT a
        FROM Aviso a
        WHERE a.Unidade.Id = :unidadeId
    """)
    Page<Aviso> listarDaUnidade(
            @Param("unidadeId") Long unidadeId,
            Pageable pageable
    );
}