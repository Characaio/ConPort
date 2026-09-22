package com.example.ecoportapi.Services;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.swing.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Service
public class ImagensService {

    private final Path diretorioUpload;
    private static final List<String> TiposPermitidos = List.of(
            "image/jpeg",
            "image/jpg",
            "image/png",
            "image/webp"
    );

    public ImagensService(
            @Value("${file.upload-dir}") String diretorioUpload
    ) {
        this.diretorioUpload = Paths.get(diretorioUpload)
                .toAbsolutePath()
                .normalize();
    }

    @Transactional
    public String salvarImagem(MultipartFile imagem) throws IOException {

        if (imagem.isEmpty()) {
            throw new IllegalArgumentException("A imagem está vazia.");
        }

        String tipo = imagem.getContentType();

        if (!TiposPermitidos.contains(tipo)) {
            throw new IllegalArgumentException(
                    "Formato de imagem não permitido"
            );
        }

        Files.createDirectories(diretorioUpload);

        String nomeOriginal = imagem.getOriginalFilename();

        String extensao = obterExtensao(nomeOriginal);

        String nomeArquivo = UUID.randomUUID() + extensao;

        Path destino = diretorioUpload.resolve(nomeArquivo);

        Files.copy(
                imagem.getInputStream(),
                destino,
                StandardCopyOption.REPLACE_EXISTING
        );

        return "/uploads/reports/" + nomeArquivo;
    }

    private String obterExtensao(String nomeArquivo) {

        if (nomeArquivo == null || !nomeArquivo.contains(".")) {
            return "";
        }

        return nomeArquivo
                .substring(nomeArquivo.lastIndexOf(".")+1)
                .toLowerCase();
    }
}