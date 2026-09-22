package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import com.example.ecoportapi.Models.Missao;
import com.example.ecoportapi.Models.Usuario;

import java.time.LocalDateTime;

public record MissaoDTO(
        Long Id,
        Usuario Usuario,
        String Nome,
        TipoMissao TipoDeMissao,
        StatusMissao StatusDeMissao,
        LocalDateTime TempoDeInicio,
        LocalDateTime TempoFechamento,
        Integer MoedaRecompensa,
        Integer XpRecompensa,
        Integer Meta,
        Integer Progresso
) {
    public MissaoDTO(Missao missao){
        this(
                missao.getId(),
                missao.getUsuario(),
                missao.getTitulo(),
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
