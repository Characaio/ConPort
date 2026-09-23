package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import com.example.ecoportapi.Models.Missao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MissaoRepository extends JpaRepository<Missao,Long> {

    @Query("""
        SELECT COUNT(m)
        FROM Missao m
        WHERE m.Usuario.Id = :usuarioId
        AND m.StatusMissao = :statusMissao
    """)
    Integer countMissoesConcluidas(Long usuarioId, StatusMissao statusMissao);
}
