package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.DTOs.Request.NotificacaoCreateDTO;
import com.example.ecoportapi.Services.NotificacaoService;
import com.example.ecoportapi.Services.SessaoInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Notificações do usuário da sessão.
 *
 * <p>O caminho é {@code /usuarios/eu/notificacoes} e o usuário vem do token.
 * Antes o id ia na URL: dava para ler, apagar e marcar como lida a notificação
 * de qualquer conta.
 */
@RestController
@RequestMapping("/usuarios/eu/notificacoes")
public class NotificacaoController {

    private final NotificacaoService notificacaoService;

    public NotificacaoController(NotificacaoService notificacaoService) {
        this.notificacaoService = notificacaoService;
    }

    @GetMapping
    @ExigeSessao
    public ResponseEntity<?> ListarNotificacoes(HttpServletRequest request) {
        return ResponseEntity.ok(notificacaoService.listar(euId(request)));
    }

    /**
     * Rota literal antes do `{notificacaoId}` do PATCH/DELETE não é conflito:
     * o Spring prefere o trecho exato ao curinga.
     */
    @GetMapping("/nao-lidas")
    @ExigeSessao
    public ResponseEntity<?> ListarNaoLidas(HttpServletRequest request) {
        return ResponseEntity.ok(notificacaoService.listarNaoLidas(euId(request)));
    }

    @GetMapping("/nao-lidas/contagem")
    @ExigeSessao
    public ResponseEntity<?> ContarNaoLidas(HttpServletRequest request) {
        return ResponseEntity.ok(notificacaoService.contarNaoLidas(euId(request)));
    }

    @PostMapping
    @ExigeSessao
    public ResponseEntity<?> CriarNotificacao(
            @RequestBody NotificacaoCreateDTO notificacaoDTO,
            HttpServletRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(notificacaoService.criar(euId(request), notificacaoDTO));
    }

    @PatchMapping("/{notificacaoId}/ler")
    @ExigeSessao
    public ResponseEntity<?> MarcarComoLida(
            @PathVariable Long notificacaoId,
            HttpServletRequest request
    ) {
        return ResponseEntity.ok(
                notificacaoService.marcarComoLida(euId(request), notificacaoId)
        );
    }

    @PatchMapping("/ler-todas")
    @ExigeSessao
    public ResponseEntity<?> MarcarTodasComoLidas(HttpServletRequest request) {
        return ResponseEntity.ok(notificacaoService.marcarTodasComoLidas(euId(request)));
    }

    @DeleteMapping("/{notificacaoId}")
    @ExigeSessao
    public ResponseEntity<?> ExcluirNotificacao(
            @PathVariable Long notificacaoId,
            HttpServletRequest request
    ) {
        notificacaoService.excluir(euId(request), notificacaoId);

        return ResponseEntity.noContent().build();
    }

    private Long euId(HttpServletRequest request) {
        return SessaoInterceptor.usuarioObrigatorio(request).getId();
    }
}
