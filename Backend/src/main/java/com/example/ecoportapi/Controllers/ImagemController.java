package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.Services.ImagemService;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/imagens")
public class ImagemController {
    private final ImagemService imagemService;

    public ImagemController(ImagemService imagemService) {
        this.imagemService = imagemService;
    }

    @GetMapping("/{nomeDaImagem}")
    public ResponseEntity<Resource> PegarImagem(
            @PathVariable String nomeDaImagem
    ){
        Resource imagem = imagemService.BuscarImagem(nomeDaImagem);

        if (imagem == null || !imagem.exists()) {
            return ResponseEntity.notFound().build();
        }

        MediaType tipo = MediaTypeFactory
                .getMediaType(imagem)
                .orElse(MediaType.APPLICATION_OCTET_STREAM);

        return ResponseEntity.ok()
                .contentType(tipo)
                .body(imagem);
    }
}
