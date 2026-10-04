package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import com.example.ecoportapi.Models.Missao;

import java.time.LocalDateTime;

public record MissaoDTO(
        Long id,
        Long usuarioId,
        String usuarioNome,
        String titulo,
        String descricao,
        TipoMissao tipoDeMissao,
        StatusMissao statusDeMissao,
        LocalDateTime tempoDeInicio,
        LocalDateTime tempoFechamento,
        Integer moedaRecompensa,
        Integer xpRecompensa,
        Integer meta,
        Integer progresso
) {
    public MissaoDTO(Missao missao){
        this(
                missao.getId(),
                missao.getUsuario().getId(),
                missao.getUsuario().getNome(),
                missao.getTitulo(),
                missao.getDescricao(),
                missao.getTipoDeMissao(),
                missao.getStatusMissao(),
                missao.getTempoDeInicio(),
                missao.getTempoFechamento(),
                missao.getMoedaRecompensa(),
                missao.getXpRecompensa(),
                missao.getMeta(),
                missao.getProgresso()
        );
    }
}