package com.example.ecoportapi.DTOs.Request;

import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;

/**
 * Quem pode abrir as listas de "quem sigo" e "Quem me segue".
 *
 * <p>Valor inválido vira 400 com os valores aceitos na mensagem: assim o app
 * descobre o enum sem precisar duplicar a lista.
 */
public record VisibilidadeDTO(VisibilidadeSeguidores visibilidade) {}
