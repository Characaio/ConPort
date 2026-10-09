package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;
import com.example.ecoportapi.Models.UsuarioPreferencia;

public record PreferenciaDTO(
        boolean perfilPublico,
        boolean permiteSolicitacoes,
        boolean notficarEmail,
        boolean compartilharLocalizacao,
        boolean dadosDeUsoAnonimo,
        VisibilidadeSeguidores visibilidadeSeguidores
) {
    public PreferenciaDTO(UsuarioPreferencia usuarioPreferencia){
        this(
                usuarioPreferencia.isPerfilPublico(),
                usuarioPreferencia.isPermiteSolicitacoes(),
                usuarioPreferencia.isNotificarEmail(),
                usuarioPreferencia.isCompartilharLocalizacao(),
                usuarioPreferencia.isDadosDeUsoAnonimo(),
                usuarioPreferencia.getVisibilidade()
        );
    }
}
