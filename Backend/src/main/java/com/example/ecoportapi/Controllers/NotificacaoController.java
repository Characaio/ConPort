package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.DTOs.Request.NotificacaoCreateDTO;
import com.example.ecoportapi.Services.NotificacaoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Notificações do usuário.
 *
 * O app chama:
 * - `GET    /usuarios/{id}/notificacoes`                  → todas
 * - `GET    /usuarios/{id}/notificacoes/nao-lidas`         → só as não lidas
 * - `GET    /usuarios/{id}/notificacoes/nao-lidas/contagem`→ só o número do sino
 * - `POST   /usuarios/{id}/notificacoes`                  → cria (201)
 * - `PATCH  /usuarios/{id}/notificacoes/{notificacaoId}/ler`
 * - `PATCH  /usuarios/{id}/notificacoes/ler-todas`
 * - `DELETE /usuarios/{id}/notificacoes/{notificacaoId}`
 */
@RestController
@RequestMapping("/usuarios/{usuarioId}/notificacoes")
public class NotificacaoController {

    private final NotificacaoService notificacaoService;

    public NotificacaoController(NotificacaoService notificacaoService) {
        this.notificacaoService = notificacaoService;
    }

    // ATENÇÃO: sem autenticação, quem lista se identifica por id na URL.
    // Mesma limitação de ConquistaController; quando existir token, o
    // usuarioId da URL deve ser trocado pelo usuário logado.

    @GetMapping
    public ResponseEntity<?> ListarNotificacoes(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(notificacaoService.listar(usuarioId));
    }

    /**
     * Rota literal antes do `{notificacaoId}` do PATCH/DELETE não é conflito:
     * o Spring prefere o trecho exato ao curinga.
     */
    @GetMapping("/nao-lidas")
    public ResponseEntity<?> ListarNaoLidas(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(notificacaoService.listarNaoLidas(usuarioId));
    }

    @GetMapping("/nao-lidas/contagem")
    public ResponseEntity<?> ContarNaoLidas(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(notificacaoService.contarNaoLidas(usuarioId));
    }

    @PostMapping
    public ResponseEntity<?> CriarNotificacao(
            @PathVariable Long usuarioId,
            @RequestBody NotificacaoCreateDTO notificacaoDTO
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(notificacaoService.criar(usuarioId, notificacaoDTO));
    }

    @PatchMapping("/{notificacaoId}/ler")
    public ResponseEntity<?> MarcarComoLida(
            @PathVariable Long usuarioId,
            @PathVariable Long notificacaoId
    ) {
        return ResponseEntity.ok(
                notificacaoService.marcarComoLida(usuarioId, notificacaoId)
        );
    }

    @PatchMapping("/ler-todas")
    public ResponseEntity<?> MarcarTodasComoLidas(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(notificacaoService.marcarTodasComoLidas(usuarioId));
    }

    @DeleteMapping("/{notificacaoId}")
    public ResponseEntity<?> ExcluirNotificacao(
            @PathVariable Long usuarioId,
            @PathVariable Long notificacaoId
    ) {
        notificacaoService.excluir(usuarioId, notificacaoId);

        return ResponseEntity.noContent().build();
    }
}
