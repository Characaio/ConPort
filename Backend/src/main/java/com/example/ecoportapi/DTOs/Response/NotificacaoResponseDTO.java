package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Notificacao;

import java.time.LocalDateTime;

/**
 * Uma notificação como o app consome.
 *
 * Os nomes dos campos são camelCase para bater exatamente com o model
 * Notificacao do Flutter (id, titulo, texto, data, lida) — é esse contrato
 * que o `Notificacao.fromJson` lê, sem precisuar conferir duas grafias como
 * acontece nos models mais antigos.
 *
 * `usuarioId` vai junto porque o app guarda a lista de vários usuários em
 * memória (troca de conta sem reiniciar o app) e sem ele não dá para saber de
 * quem é cada item depois de um merge das listas.
 */
public record NotificacaoResponseDTO(
        Long id,
        Long usuarioId,
        String titulo,
        String texto,
        LocalDateTime data,
        Boolean lida
) {
    public NotificacaoResponseDTO(Notificacao notificacao) {
        this(
                notificacao.getId(),
                notificacao.getUsuario().getId(),
                notificacao.getTitulo(),
                notificacao.getTexto(),
                notificacao.getData(),
                notificacao.getLida()
        );
    }
}
