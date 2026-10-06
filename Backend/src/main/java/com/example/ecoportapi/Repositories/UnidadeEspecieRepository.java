package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Especie;
import com.example.ecoportapi.Models.UnidadeEspecie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UnidadeEspecieRepository extends JpaRepository<UnidadeEspecie,Long> {

    @Query("""
        SELECT ue.Especie
        FROM UnidadeEspecie ue
        WHERE ue.Unidade.Id = :unidadeId
    """)
    List<Especie> findEspeciesByUnidadeId(@Param("unidadeId")final Long unidadeId);

}
