package com.example.ecoportapi.Services;

import com.drew.lang.GeoLocation;
import com.drew.metadata.exif.GpsDirectory;
import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.Exceptions.RequisicaoInvalida;
import com.example.ecoportapi.Models.Enums.ImagemDadosParametros;
import org.springframework.core.io.Resource;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.drew.metadata.Directory;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.List;

@Service
public class ImagemService {

    private final Path diretorio;

    private static final List<String> TiposPermitidos = List.of(
            "image/jpeg",
            "image/jpg",
            "image/png",
            "image/webp"
    );

    public ImagemService(
            @Value("${file.upload-dir}") String diretorioUpload
    ) {
        this.diretorio = Paths.get(diretorioUpload)
                .toAbsolutePath()
                .normalize();
    }

    public Resource BuscarImagem(String nomeArquivo){
        try {
            Path caminho = diretorio.resolve(nomeArquivo).normalize();
            Resource resource = new UrlResource(caminho.toUri());
            if (resource.exists() && resource.isReadable()) {
                return resource;
            }
            return null;
        } catch (MalformedURLException e) {
            return null;
        }
    }

    @Transactional
    public List<ImagemProcessada> SalvarImagens(List<MultipartFile> imagens) throws IOException{
        List<ImagemProcessada> imagensInfo = new ArrayList<>();
        if(imagens == null){
          return null;
        }
        for (MultipartFile imagem : imagens){
            imagensInfo.add(SalvarImagem(imagem));
        }
        return imagensInfo;
    }

    @Transactional
    public ImagemProcessada SalvarImagem(MultipartFile imagem) throws IOException {
        if (imagem.isEmpty()) {
            throw new RequisicaoInvalida("A imagem está vazia.");
        }

        String nomeOriginal = imagem.getOriginalFilename();
        String extensao = obterExtensao(nomeOriginal);

        // O Content-Type da parte nem sempre vem: o multipart do app envia
        // so o Content-Disposition quando o cliente nao informa o tipo. Sem
        // isso cair, cai no tipo derivado do nome do arquivo em vez de
        // recusar uma foto válida.
        String tipo = imagem.getContentType();

        if (tipo == null || tipo.isBlank() || !TiposPermitidos.contains(tipo)) {
            final String extensaoAtual = extensao;

            String tipoPelaExtensao = TiposPermitidos.stream()
                    .filter(t -> t.endsWith("/" + extensaoAtual))
                    .findFirst()
                    .orElse(null);

            if (tipoPelaExtensao != null) {
                tipo = tipoPelaExtensao;
            }
        }

        final String tipoFinal = tipo;

        if (!TiposPermitidos.contains(tipoFinal)) {
            throw new RequisicaoInvalida(
                    "Formato de imagem não permitido: "
                            + (tipoFinal == null ? "não informado" : tipoFinal)
            );
        }

        Files.createDirectories(diretorio);

        // Nome sem extensão (o seletor às vezes entrega isso) ainda precisa
        // gerar um arquivo com extensão, senão sobra "uuid." no disco.
        if (extensao.isEmpty()) {
            extensao = tipoFinal.endsWith("png") ? "png" : "jpg";
        }

        String nomeArquivo = UUID.randomUUID() + "." + extensao;

        Path destino = diretorio.resolve(nomeArquivo);

        Double latitude = null;
        Double longitude = null;

        Files.copy(
                imagem.getInputStream(),
                destino,
                StandardCopyOption.REPLACE_EXISTING
        );

        try {
            File imageFile = destino.toFile();
            Metadata metadata = ImageMetadataReader.readMetadata(imageFile);
            GpsDirectory gpsDirectory = metadata.getFirstDirectoryOfType(GpsDirectory.class);

            if (gpsDirectory != null && gpsDirectory.getGeoLocation() != null){
                GeoLocation location = gpsDirectory.getGeoLocation();

                latitude = location.getLatitude();
                longitude = location.getLongitude();
            }
        } catch (Exception e) {
            System.err.println("Failed to read metadata: " + e.getMessage());
            e.printStackTrace();
        }


        return new ImagemProcessada(nomeArquivo,latitude,longitude);
    }

    private String obterExtensao(String nomeArquivo) {

        if (nomeArquivo == null || !nomeArquivo.contains(".")) {
            return "";
        }

        String extensao = nomeArquivo
                .substring(nomeArquivo.lastIndexOf(".")+1)
                .toLowerCase();

        // JPEG costuma chegar como .jpg ou .jpeg; o tipo aceito é o mesmo.
        return extensao.equals("jpeg") ? "jpg" : extensao;
    }
}
