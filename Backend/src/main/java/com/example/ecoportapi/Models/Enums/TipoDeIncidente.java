package com.example.ecoportapi.Models.Enums;

public enum TipoDeIncidente {
    QUEIMADA("Queimada"),
    ANIMAL_FERIDO("Animal Ferido"),
    ANIMAL_EXOTICO("Animal Exótico"),
    POLUICAO("Poluição"),
    DESMATAMENTO("Desmatamento");

    private final String TipoPuro;

    TipoDeIncidente(String TipoPuro){
        this.TipoPuro = TipoPuro;
    }

    public static TipoDeIncidente StringParaTipo(String tipoPuro){

        for(TipoDeIncidente tipo : values()){
            if (tipo.TipoPuro.equalsIgnoreCase(tipoPuro.trim())){
                return tipo;
            }
        }
        throw new IllegalArgumentException(
                "Tipo de incidente inválido " + tipoPuro
        );

    }
}
