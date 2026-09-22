package com.example.ecoportapi.Models.Enums;

public enum TipoMissao {
    RECICLAR("Reciclar"),
    PLANTAR("Plantar"),
    REUTILIZAR("Reutilizar");

    private final String TipoPuro;

    TipoMissao(String TipoPuro){
        this.TipoPuro = TipoPuro;
    }

    public static TipoMissao StringParaTipo(String tipoPuro){

        for(TipoMissao tipo : values()){
            if (tipo.TipoPuro.equalsIgnoreCase(tipoPuro.trim())){
                return tipo;
            }
        }
        throw new IllegalArgumentException(
                "Tipo de missa" +
                        " inválido " + tipoPuro
        );

    }
}

