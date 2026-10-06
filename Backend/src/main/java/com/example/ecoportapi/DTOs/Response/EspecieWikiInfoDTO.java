package com.example.ecoportapi.DTOs.Response;

import javax.print.DocFlavor;

public record EspecieWikiInfoDTO(
        String nomeComum,
        String descricaoExpandida,
        String descricaoResumida,
        String imagemURLThumb,
        String imagemURLOriginal,
        ImagemDireitos imagemDireitos
) {}
