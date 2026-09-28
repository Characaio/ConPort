package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.Services.AvistamentoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/avistamento")
public class AvistamentoController {

    private final AvistamentoService avistamentoService;

    public AvistamentoController(AvistamentoService avistamentoService) {
        this.avistamentoService = avistamentoService;
    }

    @PostMapping
    public ResponseEntity<?> CriarAvistamento(
            @RequestPart(value="avistamentoDTO") AvistamentoCreateDTO avistamentoDTO,
            @RequestPart(value="imagem") MultipartFile imagem
            ){
        return avistamentoService.CriarAvistamento(avistamentoDTO,imagem);
    }
}
