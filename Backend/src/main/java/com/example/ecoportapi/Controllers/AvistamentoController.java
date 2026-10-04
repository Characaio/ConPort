package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.Services.SessaoInterceptor;
import jakarta.servlet.http.HttpServletRequest;
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

    /**
     * Registrar avistamento exige sessao: quem envia e o usuario do token.
     * Ler os avistamentos da unidade continua publico.
     */
    @PostMapping()
    @ExigeSessao
    public ResponseEntity<?> CriarAvistamento(
            @RequestPart(value="avistamentoDTO") AvistamentoCreateDTO avistamentoDTO,
            @RequestPart(value="imagem") MultipartFile imagem,
            @PathVariable Long unidadeId,
            HttpServletRequest request
    ) throws IOException {
        return avistamentoService.CriarAvistamento(
                avistamentoDTO,
                imagem,
                unidadeId,
                SessaoInterceptor.usuarioObrigatorio(request).getId());
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
