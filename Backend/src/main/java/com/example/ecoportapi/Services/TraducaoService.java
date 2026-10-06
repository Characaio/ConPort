package com.example.ecoportapi.Services;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import tools.jackson.databind.JsonNode;

@Service
public class TraducaoService {

    private final RestClient client;

    private final String UrlApiTraducao =
            "https://api.mymemory.translated.net";

    public TraducaoService() {
        this.client = RestClient.builder()
                .baseUrl(UrlApiTraducao)
                .build();
    }

    public String TraduzirTextoGrande(String texto) {

        int limite = 450;
        StringBuilder resultado = new StringBuilder();

        int inicio = 0;

        while (inicio < texto.length()) {

            int fim = Math.min(inicio + limite, texto.length());

            if (fim < texto.length()) {
                int ultimoEspaco = texto.lastIndexOf(" ", fim);

                if (ultimoEspaco > inicio) {
                    fim = ultimoEspaco;
                }
            }

            String parte = texto.substring(inicio, fim);

            resultado.append(Traduzir(parte));

            if (fim < texto.length()) {
                resultado.append(" ");
            }

            inicio = fim;
        }

        return resultado.toString();
    }

    public String Traduzir(String texto) {

        JsonNode resposta = client.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/get")
                        .queryParam("q", texto)
                        .queryParam("langpair", "en|pt")
                        .build())
                .retrieve()
                .body(JsonNode.class);

        if (resposta == null) {
            throw new RuntimeException(
                    "A API de tradução não retornou uma resposta."
            );
        }

        JsonNode textoTraduzido =
                resposta.path("responseData").path("translatedText");

        if (textoTraduzido.isMissingNode() || textoTraduzido.isNull()) {
            throw new RuntimeException(
                    "A API de tradução não retornou o texto traduzido."
            );
        }

        return textoTraduzido.asString();
    }
}
