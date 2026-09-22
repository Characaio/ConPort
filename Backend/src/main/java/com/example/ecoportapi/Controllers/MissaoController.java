package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.ProgressoDTO;
import com.example.ecoportapi.DTOs.Response.MissaoDTO;
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


    @GetMapping("/{id}")
    public ResponseEntity<?> PegarMissão(@PathVariable Long Id){
        return ResponseEntity.ok(missaoService.PegarMissao(Id));
    }

    @GetMapping("/{id}/progresso")
    public ResponseEntity<?> ProgredirMissao(
            @PathVariable Long id, @RequestBody ProgressoDTO progressoDTO){
        return ResponseEntity.ok(missaoService.ProgredirMissao(id,progressoDTO));
    }

}
