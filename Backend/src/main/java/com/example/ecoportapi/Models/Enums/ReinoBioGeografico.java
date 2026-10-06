package com.example.ecoportapi.Models.Enums;

import com.example.ecoportapi.Exceptions.ReinoBioGeograficoNaoEncontrado;

import java.util.Arrays;

public enum ReinoBioGeografico {

    AFROTROPICAL("Afrotropical"),
    ANTARCTIC("Antarctic"),
    AUSTRALASIAN("Australasian"),
    INDO_MALAYAN("Indomalayan"),
    NEARCTIC("Nearctic"),
    NEOTROPICAL("Neotropical"),
    OCEANIAN("Oceanian"),
    PALEARCTIC("Palearctic");

    private final String nomeApi;

    ReinoBioGeografico(String nomeApi) {
        this.nomeApi = nomeApi;
    }

    public static ReinoBioGeografico fromNome(String nome) {
        return Arrays.stream(values())
                .filter(reino -> reino.nomeApi.equalsIgnoreCase(nome))
                .findFirst()
                .orElseThrow(() ->
                        new ReinoBioGeograficoNaoEncontrado(
                                "Reino biogeográfico desconhecido: " + nome
                        )
                );
    }
    public String getNomeApi() {
        return nomeApi;
    }
}
