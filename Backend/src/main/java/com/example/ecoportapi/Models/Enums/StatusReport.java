package com.example.ecoportapi.Models.Enums;

import java.text.Normalizer;

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

    /**
     * Aceita o nome do enum ("EM_TRATAMENTO"), o rótulo ("Em tratamento")
     * ou variantes com acento.
     */
    public static StatusReport StringParaTipo(String tipoPuro){

        if (tipoPuro == null || tipoPuro.isBlank()){
            throw new IllegalArgumentException("Status não informado");
        }

        String busca = tipoPuro.trim();

        for (StatusReport tipo : values()){
            if (tipo.name().equalsIgnoreCase(busca)
                    || tipo.TipoPuro.equalsIgnoreCase(busca)){
                return tipo;
            }
        }

        String normalizado = normalizar(busca);

        for (StatusReport tipo : values()){
            if (normalizar(tipo.name()).equals(normalizado)
                    || normalizar(tipo.TipoPuro).equals(normalizado)){
                return tipo;
            }
        }

        throw new IllegalArgumentException(
                "Tipo de status inválido " + tipoPuro
        );

    }

    /** Remove acentos, espaços e hífens para comparar textos parecidos. */
    private static String normalizar(String texto){
        String semAcento =
                Normalizer.normalize(texto, Normalizer.Form.NFD)
                        .replaceAll("\\p{M}", "");

        return semAcento.replaceAll("[\\s_-]", "").toLowerCase();
    }
}
