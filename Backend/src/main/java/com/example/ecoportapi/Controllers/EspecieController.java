package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Models.Enums.TipoEspecie;
import com.example.ecoportapi.Services.EspecieService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Especies registradas na unidade.
 *
 * O app chama `GET /unidade/{unidadeId}/especies?tipo=FAUNA` para montar as
 * duas grades da tela de ecossistema.
 */
@RestController
@RequestMapping("/unidade/{unidadeId}/especies")
public class EspecieController {

    private final EspecieService especieService;

    public EspecieController(EspecieService especieService) {
        this.especieService = especieService;
    }

    @GetMapping
    public ResponseEntity<?> Listar(
            @PathVariable Long unidadeId,
            @RequestParam(defaultValue = "FAUNA") TipoEspecie tipo
    ) {
        return ResponseEntity.ok(especieService.listar(unidadeId, tipo));
    }
}