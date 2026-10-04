package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.ProgressoDTO;
import com.example.ecoportapi.Services.MissaoService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/missoes")
public class MissaoController {

    private final MissaoService missaoService;

    public MissaoController(MissaoService missaoService) {
        this.missaoService = missaoService;
    }

    @GetMapping
    public ResponseEntity<?> ListarMissoes(@RequestParam Long usuarioId){
        // ATENÇÃO: sem autenticação, quem lista se identifica por query string.
        // Substituir pelo usuario logado quando existir token.
        return ResponseEntity.ok(missaoService.listarMissoes(usuarioId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> PegarMissao(@PathVariable Long id){
        return ResponseEntity.ok(missaoService.PegarMissao(id));
    }

    @PostMapping("/{id}/progresso")
    public ResponseEntity<?> ProgredirMissao(
            @PathVariable Long id, @RequestBody ProgressoDTO progressoDTO){
        return ResponseEntity.ok(missaoService.ProgredirMissao(id,progressoDTO));
    }

}