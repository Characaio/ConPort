package com.example.ecoportapi.DTOs.Request;

/**
 * Confirmação de exclusão de conta.
 *
 * <p>A senha é exigida porque a rota usa só o token: com o token valendo, uma
 * tela aberta num aparelho emprestado já apagaria a conta. Pedir a senha troca
 * esse risco por "quem está usando o aparelho precisa saber a senha".
 */
public record ExcluirContaDTO(String senha) {}
