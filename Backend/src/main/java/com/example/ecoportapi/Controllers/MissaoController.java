package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.DTOs.Request.ProgressoDTO;
import com.example.ecoportapi.Services.MissaoService;
import com.example.ecoportapi.Services.SessaoInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Missões do usuário da sessão.
 *
 * <p>Antes a listagem vinha por {@code ?usuarioId=} na query, o que deixava
 * qualquer um ver e mexer no progresso de qualquer conta. Agora o usuário vem
 * do token.
 */
@RestController
@RequestMapping("/missoes")
public class MissaoController {

    private final MissaoService missaoService;

    public MissaoController(MissaoService missaoService) {
        this.missaoService = missaoService;
    }

    @GetMapping
    @ExigeSessao
    public ResponseEntity<?> ListarMissoes(HttpServletRequest request) {
        return ResponseEntity.ok(missaoService.listarMissoes(euId(request)));
    }

    @GetMapping("/{id}")
    @ExigeSessao
    public ResponseEntity<?> PegarMissao(@PathVariable Long id) {
        return ResponseEntity.ok(missaoService.PegarMissao(id));
    }

    @PostMapping("/{id}/progresso")
    @ExigeSessao
    public ResponseEntity<?> ProgredirMissao(
            @PathVariable Long id, @RequestBody ProgressoDTO progressoDTO) {
        return ResponseEntity.ok(missaoService.ProgredirMissao(id, progressoDTO));
    }

    private Long euId(HttpServletRequest request) {
        return SessaoInterceptor.usuarioObrigatorio(request).getId();
    }
}
