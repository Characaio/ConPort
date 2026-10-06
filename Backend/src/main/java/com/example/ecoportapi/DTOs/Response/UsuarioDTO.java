package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Usuario;

import java.time.LocalDate;

public record UsuarioDTO(
    Long Id,
    String Nome,
    LocalDate DataNasc,
    String Email,
    String Senha,
    String Estado,
    String Cidade,
    boolean Confiavel,
    Integer XP,
    Integer Level,
    Integer Moedas
) {
    public UsuarioDTO(Usuario usuario
    ){
        this(
                usuario.getId(),
                usuario.getNome(),
                usuario.getDataNasc(),
                usuario.getEmail(),
                usuario.getSenha(),
                usuario.getEstado(),
                usuario.getCidade(),
                usuario.isConfiavel(),
                usuario.getXP(),
                usuario.getLevel(),
                usuario.getMoedas()
        );
    }
}
