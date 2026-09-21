package com.example.ecoportapi.Models.Enums;

public enum TipoDeUnidade {
    //Proteção Integral
    PARQUE_NACIONAL("Parque Nacional"),
    RESERVA_BIOLOGICA("Reserva Biológica"),
    MONUMENTO_NATURAL("Monumento Natural"),

    //Uso Sustentavel
    FLONA("Flona"),
    RESERVA_EXTRATIVISTA("Reserva Extrativista"),
    RPPN("Rppn");

    private final String TipoPuro;

    TipoDeUnidade(String tipoPuro) { this.TipoPuro = tipoPuro; }

    public static TipoDeUnidade StringParaTipo(String tipoPuro){
        for (TipoDeUnidade tipo : values()){
            if (tipo.TipoPuro.equalsIgnoreCase(tipoPuro.trim())){
                return tipo;
            }
        }
        throw new IllegalArgumentException(
                "Tipo de Unidade Invalida " + tipoPuro
        );
    }

}
