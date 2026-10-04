package com.example.ecoportapi.Models.Enums;

import java.text.Normalizer;

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

    /**
     * Aceita o nome do enum ("POLUICAO"), o rótulo ("Poluição") ou qualquer
     * variante com acento, para o frontend poder mandar os dois.
     */
    public static TipoDeIncidente StringParaTipo(String tipoPuro){

        if (tipoPuro == null || tipoPuro.isBlank()){
            throw new IllegalArgumentException("Tipo de incidente não informado");
        }

        String busca = tipoPuro.trim();

        for (TipoDeIncidente tipo : values()){
            if (tipo.name().equalsIgnoreCase(busca)
                    || tipo.TipoPuro.equalsIgnoreCase(busca)){
                return tipo;
            }
        }

        // Ultimo recurso: comparar sem acento nem separador.
        String normalizado = normalizar(busca);

        for (TipoDeIncidente tipo : values()){
            if (normalizar(tipo.name()).equals(normalizado)
                    || normalizar(tipo.TipoPuro).equals(normalizado)){
                return tipo;
            }
        }

        throw new IllegalArgumentException(
                "Tipo de incidente inválido " + tipoPuro
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
