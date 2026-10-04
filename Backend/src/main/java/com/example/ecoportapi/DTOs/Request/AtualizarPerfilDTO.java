package com.example.ecoportapi.DTOs.Request;

import java.time.LocalDate;

/**
 * Atualização parcial de perfil: todo campo é opcional e quem vem nulo fica
 * como está. Isso deixa o app mandar só o que a pessoa mexeu.
 *
 * <p>A senha é a única que exige {@code senhaAtual} — sem ela, trocar a senha
 * seria só trocar a senha de qualquer conta, porque as rotas ainda não têm
 * autenticação.
 */
public record AtualizarPerfilDTO(
        String nome,
        String username,
        String email,
        LocalDate dataNasc,
        String cidade,
        String estado,
        String senha,
        String senhaAtual) {}
