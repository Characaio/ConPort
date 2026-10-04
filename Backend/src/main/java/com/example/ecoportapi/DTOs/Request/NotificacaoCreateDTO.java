package com.example.ecoportapi.DTOs.Request;

/**
 * Corpo do `POST /usuarios/{id}/notificacoes`.
 *
 * Os nomes dos campos são camelCase (e não PascalCase como em AvisoCreateDTO)
 * porque é o app que monta esse JSON e o model Notificacao do Flutter já usa
 * `titulo`/`texto`.
 *
 * O usuário NÃO vem no corpo: quem recebe a notificação é o usuário da URL,
 * senão dava para criar notificação para outra pessoa mudando um campo.
 */
public record NotificacaoCreateDTO(
        String titulo,
        String texto
) {
}
