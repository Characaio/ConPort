package com.example.ecoportapi.Models.Enums;

import java.util.Locale;

public enum PerigoDeExtincao {

    NAO_AVALIADO("NE"),
    DADOS_INSUFICIENTES("DD"),
    MENOS_PREOCUPANTE("LC"),
    QUASE_AMENACADO("NT"),
    VULNERAVEL("VU"),
    EM_PERIGO("EN"),
    CRITICAMENTE_EM_PERIGO("CR"),
    EXTINTO_NA_NATUREZA("EW"),
    EXTINTO("EX");

    private final String codigo;

    PerigoDeExtincao(String codigo) {
        this.codigo = codigo;
    }

    public static PerigoDeExtincao fromCodigo(String codigo) {
        for (PerigoDeExtincao status : values()) {
            if (status.codigo.equalsIgnoreCase(codigo)) {
                return status;
            }
        }

        throw new IllegalArgumentException(
                "Código de conservação inválido: " + codigo
        );
    }
}