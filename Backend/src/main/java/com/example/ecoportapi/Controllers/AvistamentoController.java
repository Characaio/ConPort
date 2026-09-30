package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.DTOs.Response.AvistamentoDTO;
import com.example.ecoportapi.Services.AvistamentoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/unidade/{unidadeId}/avistamento")
public class AvistamentoController {

    private final AvistamentoService avistamentoService;

    public AvistamentoController(AvistamentoService avistamentoService) {
        this.avistamentoService = avistamentoService;
    }

    @PostMapping()
    public ResponseEntity<?> CriarAvistamento(
            @RequestPart(value="avistamentoDTO") AvistamentoCreateDTO avistamentoDTO,
            @RequestPart(value="imagem") MultipartFile imagem,
            @PathVariable Long id
    ) throws IOException {
        return avistamentoService.CriarAvistamento(
                avistamentoDTO,
                imagem,
                id);
    }

    @GetMapping()
    public ResponseEntity<?> PegarAvistamentosDaUnidade(
            @PathVariable Long unidadeId
    ){
        return ResponseEntity.ok(avistamentoService.PegarAvistamentosDaUnidade(unidadeId));
    }

    @GetMapping("/{avistamentoId}")
    public ResponseEntity<?> PegarAvistamento(
            @PathVariable Long avistamentoId
    ){
        return ResponseEntity.ok(avistamentoService.PegarAvistamento(avistamentoId));
    }


}
