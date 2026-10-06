package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.EspecieRequestDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeEspecieDTO;
import com.example.ecoportapi.Services.EspecieService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/unidade/{unidadeId}/especies")
public class EspecieController {

    private final EspecieService especieService;

    public EspecieController(
            EspecieService especieService
    ){
        this.especieService = especieService;
    }

    @GetMapping
    public ResponseEntity<?> PegarEspeciesDaUnidade(
            @PathVariable Long unidadeId
    ){

        return ResponseEntity.ok(
                especieService.PegarEspeciesDaUnidade(unidadeId)
        );
    }

    @GetMapping("/{especieUnidadeId}")
    public ResponseEntity<?> PegarEspecie(
            @PathVariable Long especieUnidadeId
    ){
        return ResponseEntity.ok(especieService.PegarEspecieDaUnidade(especieUnidadeId));
    }

    @PostMapping()
    public ResponseEntity<?> CadastrarEspecie(
            @PathVariable Long unidadeId,
            @RequestBody EspecieRequestDTO especieRequestDTO
    ) throws IOException, InterruptedException {
        return ResponseEntity.ok(
                especieService.CadastrarEspecie(especieRequestDTO,unidadeId)
        );
    }
}
