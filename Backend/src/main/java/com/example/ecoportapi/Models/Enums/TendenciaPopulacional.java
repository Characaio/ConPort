package com.example.ecoportapi.Models.Enums;

public enum TendenciaPopulacional {
    Aumentando("Increasing"),
    Diminuindo("Decreasing"),
    Estavel("Stable"),
    Desconhecido("Unknown");

    private final String codigo;

    TendenciaPopulacional(String codigo) {
        this.codigo = codigo;
    }

    public static TendenciaPopulacional fromCodigo(String codigo) {
        for (TendenciaPopulacional status : values()) {
            if (status.codigo.equalsIgnoreCase(codigo)) {
                return status;
            }
        }

        throw new IllegalArgumentException(
                "Código de conservação inválido: " + codigo
        );
    }
}
