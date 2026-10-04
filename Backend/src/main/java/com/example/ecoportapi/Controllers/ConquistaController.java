package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Services.ConquistaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Conquistas do usuário.
 *
 * O app chama `GET /usuarios/{id}/conquistas` para carregar o progresso e
 * `POST /usuarios/{id}/conquistas/{chave}` para desbloquear uma.
 */
@RestController
@RequestMapping("/usuarios/{usuarioId}/conquistas")
public class ConquistaController {

    private final ConquistaService conquistaService;

    public ConquistaController(ConquistaService conquistaService) {
        this.conquistaService = conquistaService;
    }

    // ATENÇÃO: sem autenticação, o progresso vem por id na URL.
    // Substituir pelo usuario logado quando existir token.
    @GetMapping
    public ResponseEntity<?> ListarDesbloqueadas(
            @PathVariable Long usuarioId
    ) {
        return ResponseEntity.ok(conquistaService.listarDesbloqueadas(usuarioId));
    }

    @PostMapping("/{chave}")
    public ResponseEntity<?> Desbloquear(
            @PathVariable Long usuarioId,
            @PathVariable String chave
    ) {
        return conquistaService.desbloquear(usuarioId, chave);
    }
}