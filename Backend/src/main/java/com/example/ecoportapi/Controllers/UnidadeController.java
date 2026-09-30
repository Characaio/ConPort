package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Services.UnidadeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/unidade/{unidadeId}")
public class UnidadeController {

    private final UnidadeService unidadeService;

    public UnidadeController(UnidadeService unidadeService) {
        this.unidadeService = unidadeService;
    }

    @GetMapping("/informacoes")
    public ResponseEntity<?> PegarInformacoes(@PathVariable Long unidadeId){
        return ResponseEntity.ok(
                unidadeService.PegarInformacoes(unidadeId)
        );
    }

    @GetMapping()
    public ResponseEntity<?> PegarStatus(@PathVariable Long unidadeId){
        return ResponseEntity.ok(
                unidadeService.PegarStatus(unidadeId)
        );
    }








}
