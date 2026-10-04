package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.LocalizacaoOrigem;

/**
 * Avistamento que o app envia.
 *
 * <p>Não tem `UsuarioId`: quem envia é o usuário do token, e aceitar o id no
 * corpo deixava dava para avistar em nome de outra pessoa.
 */
public record AvistamentoCreateDTO(
    Double Longitude,
    Double Latitude,
    LocalizacaoOrigem Origem,
    Long UnidadeId) {}
