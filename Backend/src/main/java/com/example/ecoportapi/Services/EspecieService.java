package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.EspecieRequestDTO;
import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Exceptions.EspecieNaoEncontrada;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Models.Enums.PerigoDeExtincao;
import com.example.ecoportapi.Models.Enums.ReinoBioGeografico;
import com.example.ecoportapi.Models.Enums.TendenciaPopulacional;
import com.example.ecoportapi.Models.Especie;
import com.example.ecoportapi.Models.UnidadeEspecie;
import com.example.ecoportapi.Repositories.EspecieRepository;
import com.example.ecoportapi.Repositories.UnidadeEspecieRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.jsoup.Jsoup;
import org.jspecify.annotations.NonNull;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URI;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;


@Service
public class EspecieService {

    private final EspecieRepository especieRepository;
    private final UnidadeRepository unidadeRepository;
    private final UnidadeEspecieRepository unidadeEspecieRepository;
    private final TraducaoService traducaoService;
    private final ObjectMapper objectMapper;
    private final String RedListURL = "https://api.iucnredlist.org";
    private final String Token = "RtArJjPhcd92YhDABCUET4msj9ns7h28cecr";
    private final HttpClient client = HttpClient.newHttpClient();
    public EspecieService(
            EspecieRepository especieRepository, UnidadeRepository unidadeRepository, UnidadeEspecieRepository unidadeEspecieRepository,
            TraducaoService traducaoService
    ){
        this.especieRepository = especieRepository;
        this.unidadeRepository = unidadeRepository;
        this.unidadeEspecieRepository = unidadeEspecieRepository;
        this.traducaoService = traducaoService;
        this.objectMapper = new ObjectMapper();
    }

    private String extrairNomeArquivo(String imageUrl) {
        String path = URI.create(imageUrl).getPath();

        String nomeArquivo = path.substring(path.lastIndexOf('/') + 1);

        // Remove o prefixo da thumbnail, ex.: 330px-
        if (nomeArquivo.matches("\\d+px-.*")) {
            nomeArquivo = nomeArquivo.substring(nomeArquivo.indexOf('-') + 1);
        }

        return URLDecoder.decode(nomeArquivo, StandardCharsets.UTF_8);
    }

    private String pegarMetadata(JsonNode metadata, String campo) {
        JsonNode node = metadata.get(campo);

        if (node == null || node.get("value") == null) {
            return null;
        }

        return Jsoup.parse(node.get("value").asString()).text();
    }

    private EspecieWikiInfoDTO PegarInformacoesWikipedia(String nomeCientificoCompleto) throws IOException, InterruptedException {

        String Wikipedia1URL = "https://pt.wikipedia.org/w/rest.php/v1/search/page";
        String Wikipedia2URL = "https://pt.wikipedia.org/api/rest_v1/page/summary";
        String WikipediaImgURL = "https://commons.wikimedia.org/w/api.php?action=query&titles=PLACEHOLDER&prop=imageinfo&iiprop=extmetadata&format=json";

        String URLRequestWikipedia = String.format(
                "%s?q=%s&limit=1",
                Wikipedia1URL,
                URLEncoder.encode(nomeCientificoCompleto, StandardCharsets.UTF_8)
        );

        HttpRequest requestwiki = HttpRequest.newBuilder(
                        URI.create(URLRequestWikipedia))
                .header("accept", "application/json")
                .header("User-Agent", "ConPort/1.0 (projeto educacional)")
                .GET()
                .build();

        HttpResponse<String> responseWikpedia = client.send(
                requestwiki,
                HttpResponse.BodyHandlers.ofString()
        );


        if (responseWikpedia.statusCode() != 200) {
            throw new IllegalStateException(
                    "Erro ao consultar Wikipédia. HTTP: "
                            + responseWikpedia.statusCode()
            );
        }

        JsonNode jsonWikipedia1 = objectMapper.readTree(responseWikpedia.body());

        JsonNode pages = jsonWikipedia1.get("pages");

        if (pages == null || !pages.isArray() || pages.isEmpty()) {
            throw new IllegalArgumentException(
                    "Nenhuma página encontrada na Wikipédia para: " + nomeCientificoCompleto
            );
        }

        String titulo = pages.get(0).get("title").asString();

        String tituloEncoded = URLEncoder.encode(
                titulo,
                StandardCharsets.UTF_8
        ).replace("+", "%20");

        String URLRequestWikipediaMainInfo = String.format(
                "%s/%s",
                Wikipedia2URL,
                tituloEncoded
        );

        HttpRequest requestwiki2 = HttpRequest.newBuilder(
                        URI.create(URLRequestWikipediaMainInfo))
                .header("accept", "application/json")
                .header("User-Agent", "ConPort/1.0 (projeto educacional)")
                .GET()
                .build();

        HttpResponse<String> responseWikipediaMainInfo = client.send(
                requestwiki2,
                HttpResponse.BodyHandlers.ofString()
        );



        if (responseWikipediaMainInfo.statusCode() != 200) {
            throw new IllegalStateException(
                    "Erro ao consultar Wikipédia. HTTP: "
                            + responseWikipediaMainInfo.statusCode()
            );
        }

        JsonNode jsonWikipediaMainInfo = objectMapper.readTree(responseWikipediaMainInfo.body());

        JsonNode originalImage = jsonWikipediaMainInfo.get("originalimage");

        if (originalImage == null || originalImage.get("source") == null) {
            throw new IllegalArgumentException(
                    "A página da Wikipédia não possui imagem original."
            );
        }

        String imagemOriginalURL = originalImage.get("source").asString();

        String imagemOriginalNome = "File:"+ extrairNomeArquivo(imagemOriginalURL);

        JsonNode thumbnail = jsonWikipediaMainInfo.get("thumbnail");

        String imgNomeEncoded = URLEncoder.encode(
                imagemOriginalNome,
                StandardCharsets.UTF_8
        );

        String imagemThumb = null;

        if (thumbnail != null && thumbnail.get("source") != null) {
            imagemThumb = thumbnail.get("source").asString();
        }


        String URLRequestWikipediaImg = WikipediaImgURL.replace(
                "PLACEHOLDER",
                imgNomeEncoded
        );

        HttpRequest requestWikiImg = HttpRequest.newBuilder(
                        URI.create(URLRequestWikipediaImg))
                .header("accept", "application/json")
                .header("User-Agent", "ConPort/1.0 (projeto educacional)")
                .GET()
                .build();

        HttpResponse<String> responseWikiImg = client.send(
                requestWikiImg,
                HttpResponse.BodyHandlers.ofString()
        );

        if (responseWikiImg.statusCode() != 200) {
            throw new IllegalStateException(
                    "Erro ao consultar Wikipédia. HTTP: "
                            + responseWikiImg.statusCode()
            );
        }

        JsonNode jsonWikipediaImg = objectMapper.readTree(responseWikiImg.body());

        JsonNode page = null;

        for (var propriedade : jsonWikipediaImg.get("query")
                .get("pages").properties()) {

            page = propriedade.getValue();
            break;
        }

        if (page == null || page.isMissingNode()) {
            throw new IllegalArgumentException(
                    "Imagem não encontrada no Wikimedia Commons: " + imgNomeEncoded
            );
        }

        JsonNode imageInfo = page.get("imageinfo");

        if (imageInfo == null || !imageInfo.isArray() || imageInfo.isEmpty()) {
            throw new IllegalArgumentException(
                    "O Commons não retornou informações da imagem: " + imgNomeEncoded
            );
        }

        JsonNode metadata = imageInfo.get(0).get("extmetadata");

        if (metadata == null) {
            throw new IllegalArgumentException(
                    "A imagem não possui metadados no Wikimedia Commons: " + imgNomeEncoded
            );
        }

        ImagemDireitos imagemDireitos = new ImagemDireitos(
                pegarMetadata(metadata, "Artist"),
                pegarMetadata(metadata, "LicenseShortName"),
                pegarMetadata(metadata, "UsageTerms")
        );

        return new EspecieWikiInfoDTO(
                jsonWikipediaMainInfo.get("title").asString(),
                traducaoService.TraduzirTextoGrande(
                        Jsoup
                        .parse(
                                jsonWikipediaMainInfo
                                        .get("extract")
                                        .asString()
                        ).text()
                ),
                traducaoService.Traduzir(
                        Jsoup
                        .parse(
                                jsonWikipediaMainInfo
                                .get("description")
                                .asString()
                        ).text()
                ),
                imagemThumb,
                imagemOriginalNome,
                imagemDireitos
        );
    }

    private Long PegarAssementId(EspecieRequestDTO especieDTO) throws IOException, InterruptedException {

        String genus = URLEncoder.encode(
                especieDTO.genus(),
                StandardCharsets.UTF_8
        );

        String species = URLEncoder.encode(
                especieDTO.especie(),
                StandardCharsets.UTF_8
        );

        String URLRequest = String.format(
                "%s/api/v4/taxa/scientific_name?genus_name=%s&species_name=%s",
                RedListURL,
                genus,
                species
        );

        HttpRequest requestAssesement = HttpRequest.newBuilder(
                        URI.create(URLRequest))
                .header("accept", "application/json")
                .header("Authorization",  Token)
                .build();

        HttpResponse<String> responseAssesement = client.send(
                requestAssesement,
                HttpResponse.BodyHandlers.ofString()
        );


        if (responseAssesement.statusCode() != 200) {
            throw new IllegalStateException(
                    "Erro ao pegar o IUCN. HTTP: "
                            + responseAssesement.statusCode()
            );
        }
        JsonNode json = objectMapper.readTree(responseAssesement.body());

        JsonNode assessments = json.get("assessments");

        if (assessments == null || !assessments.isArray() || assessments.isEmpty()) {
            throw new IllegalArgumentException(
                    "A API da IUCN não retornou avaliações para a espécie."
            );
        }

        JsonNode assessment = assessments.get(0);

        JsonNode assessmentId = assessment.get("assessment_id");

        if (assessmentId == null || assessmentId.isNull()) {
            throw new IllegalArgumentException(
                    "A API da IUCN não retornou um assessment_id."
            );
        }

        return assessmentId.asLong();

    }

    private EspecieRedListInfoDTO PegarInformacoes(EspecieRequestDTO especieDTO) throws IOException, InterruptedException {

        Long assessmentId = PegarAssementId(especieDTO);

        String URLRequestRedList = String.format(
                "%s/api/v4/assessment/%d",
                RedListURL, assessmentId
        );


        HttpRequest requestRedList = HttpRequest.newBuilder(
                        URI.create(URLRequestRedList))
                .header("accept", "application/json")
                .header("Authorization", Token)
                .build();

        HttpResponse<String> responseRedList = client.send(
                requestRedList,
                HttpResponse.BodyHandlers.ofString()
        );

        if (responseRedList.statusCode() != 200) {
            throw new IllegalStateException(
                    "Erro ao consultar Wikipédia. HTTP: "
                            + responseRedList.statusCode()
            );
        }

        JsonNode jsonRedList = objectMapper.readTree(responseRedList.body());

        JsonNode jsonTaxon = jsonRedList.get("taxon");

        if (jsonTaxon == null || jsonTaxon.isNull()) {
            throw new IllegalArgumentException(
                    "A IUCN não retornou os dados taxonômicos da espécie."
            );
        }

        List<ReinoBioGeografico> reinosBioGeograficos = new ArrayList<>();

        JsonNode reinos = jsonRedList
                .path("biogeographical_realms")
                .path("description")
                .path("en");

        if (reinos.isArray()) {
            for (JsonNode node : reinos) {
                String nome = node.asString();

                reinosBioGeograficos.add(
                        ReinoBioGeografico.fromNome(nome)
                );

            }
        }

        List<String> habitats = new ArrayList<>();

        JsonNode arrayNodeHabitat = jsonRedList.get("habitats");

        if (arrayNodeHabitat != null && arrayNodeHabitat.isArray()) {

            for (JsonNode node : arrayNodeHabitat) {

                String habitatOriginal = node
                        .path("description")
                        .path("en")
                        .asString(null);

                if (habitatOriginal != null) {
                    habitats.add(
                            traducaoService.Traduzir(habitatOriginal)
                    );
                }
            }
        }

        String tendencia = jsonRedList
                .path("population_trend")
                .path("description")
                .path("en")
                .asString(null);

        TendenciaPopulacional tendenciaPopulacional = null;

        if (tendencia != null) {
            tendenciaPopulacional =
                    TendenciaPopulacional.fromCodigo(tendencia);
        }

        String codigoPerigo = jsonRedList
                .path("red_list_category")
                .path("code")
                .asString();

        if (codigoPerigo == null) {
            throw new IllegalArgumentException(
                    "A IUCN não retornou a categoria de conservação."
            );
        }

        PerigoDeExtincao perigo =
                PerigoDeExtincao.fromCodigo(codigoPerigo);

        return new EspecieRedListInfoDTO(
                jsonTaxon.get("scientific_name").asString(),
                jsonTaxon.get("kingdom_name").asString(),
                jsonTaxon.get("phylum_name").asString(),
                jsonTaxon.get("class_name").asString(),
                jsonTaxon.get("order_name").asString(),
                jsonTaxon.get("family_name").asString(),
                jsonTaxon.get("genus_name").asString(),
                jsonTaxon.get("species_name").asString(),
                habitats,
                reinosBioGeograficos,
                tendenciaPopulacional,
                perigo
        );
    }

    public EspecieDTO CadastrarEspecie(EspecieRequestDTO especieDTO,Long unidadeId) throws IOException, InterruptedException {

        EspecieRedListInfoDTO redListInfoDTO = PegarInformacoes(especieDTO);

        EspecieWikiInfoDTO wikiInfoDTO = PegarInformacoesWikipedia(
                String.format("%s %s",especieDTO.genus(),especieDTO.especie())
        );

        Especie especie = CriarEspecie(redListInfoDTO, wikiInfoDTO);

        Especie especieSalva = especieRepository.save(especie);

        UnidadeEspecie unidadeEspecie = new UnidadeEspecie();

        unidadeEspecie.setEspecie(especieSalva);
        unidadeEspecie.setUnidade(unidadeRepository.findById(unidadeId)
                .orElseThrow(
                        () -> new UnidadeNaoEncontrada("Unidade não foi encontrada")
                ));

        unidadeEspecieRepository.save(unidadeEspecie);

        return new EspecieDTO(especieSalva);
    }

    private Especie CriarEspecie(
            EspecieRedListInfoDTO redListInfoDTO,
            EspecieWikiInfoDTO wikiInfoDTO
    ) {
        Especie especie = new Especie();

        especie.setNomeCientifico(
                String.format(
                        "%s %s",
                        redListInfoDTO.genus(),redListInfoDTO.especie()
                )
        );
        especie.setReino(redListInfoDTO.reino());
        especie.setFilo(redListInfoDTO.filo());
        especie.setClasse(redListInfoDTO.classe());
        especie.setOrdem(redListInfoDTO.ordem());
        especie.setFamilia(redListInfoDTO.familia());
        especie.setGenus(redListInfoDTO.genus());
        especie.setEspecie(redListInfoDTO.especie());
        especie.setHabitats(redListInfoDTO.habitats());
        especie.setReinosBioGeograficos(redListInfoDTO.reinosBioGeograficos());
        especie.setTendenciaPopulacional(redListInfoDTO.tendenciaPopulacional());
        especie.setPerigoDeExtincao(redListInfoDTO.perigoDeExtincao());
        especie.setNomeComum(wikiInfoDTO.nomeComum());
        especie.setDescricaoExpandida(wikiInfoDTO.descricaoExpandida());
        especie.setDescricaoResumida(wikiInfoDTO.descricaoResumida());

        especie.setImagemURLThumb(wikiInfoDTO.imagemURLThumb());
        especie.setImagemURLOriginal(wikiInfoDTO.imagemURLOriginal());

        especie.setAutorDaImagem(wikiInfoDTO.imagemDireitos().autorDaImagem());
        especie.setLicenca(wikiInfoDTO.imagemDireitos().licence());
        especie.setTermosDeUso(wikiInfoDTO.imagemDireitos().termosDeUso());

        return especie;
    }

    public List<EspecieDTO> PegarEspeciesDaUnidade(Long unidadeId){
        return unidadeEspecieRepository
                .findEspeciesByUnidadeId(unidadeId)
                .stream().map(EspecieDTO::new).toList();
    }

    public EspecieDTO PegarEspecieDaUnidade(Long especieId){
        return new EspecieDTO(
                especieRepository.findById(especieId)
                        .orElseThrow(
                                () -> new EspecieNaoEncontrada("Especie não encontrada")
                        )
        );
    }
}
