package com.example.ecoportapi.Models.Enums;

import javax.crypto.SealedObject;

public enum StatusReport {
    PENDENTE("Pendente"),
    SOB_AVALIACAO("Sob avaliação"),
    NEGADO("Negado"),
    ACEITO("Aceito"),
    EM_TRATAMENTO("Em tratamento"),
    TRATADO("Tratado");

    private final String TipoPuro;

    StatusReport(String TipoPuro){
        this.TipoPuro = TipoPuro;
    }

    public static StatusReport StringParaTipo(String tipoPuro){

        for(StatusReport tipo : values()){
            if (tipo.TipoPuro.equalsIgnoreCase(tipoPuro.trim())){
                return tipo;
            }
        }
        throw new IllegalArgumentException(
                "Tipo de status inválido " + tipoPuro
        );

    }
}
