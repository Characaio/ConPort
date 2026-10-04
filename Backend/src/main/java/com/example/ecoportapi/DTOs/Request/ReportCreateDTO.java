package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.ReportPrioridade;

/**
 * Report que o app envia.
 *
 * <p>Não tem `UsuarioId`: quem envia é o usuário do token. Aceitar o id no
 * corpo permitiria postar em nome de outra pessoa.
 */
public record ReportCreateDTO(
    String Tipo,
    String Descricao,
    ReportPrioridade Prioridade,
    String DataDoOcorrido) {}
