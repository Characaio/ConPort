package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import com.example.ecoportapi.Models.Missao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MissaoRepository extends JpaRepository<Missao,Long> {

    @Query("""
        SELECT COUNT(r)
        FROM Report r
        WHERE r.usuario.id = :usuarioId
        AND r.status = :statusMissao
    """)
    Integer countMissoesConcluidas(Long usuarioId, StatusMissao statusMissao);
}
