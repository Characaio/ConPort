package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;

public record PreferenciaUpdateDTO(
        boolean perfilPublico,
        boolean permiteSolicitacoes,
        boolean notficarEmail,
        boolean compartilharLocalizacao,
        boolean dadosDeUsoAnonimo,
        VisibilidadeSeguidores visibilidadeSeguidores
) {
}
