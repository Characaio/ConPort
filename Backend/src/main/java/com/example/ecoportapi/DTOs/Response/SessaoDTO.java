package com.example.ecoportapi.DTOs.Response;

/**
 * O que login e cadastro devolvem: o token para o header e o usuário já
 * no formato do perfil.
 *
 * <p>Devolver o usuário junto evita uma segunda chamada logo depois do login,
 * e evita o app mostrar a tela logada antes de saber o nome de quem entrou.
 */
public record SessaoDTO(String Token, UsuarioDTO Usuario) {}
