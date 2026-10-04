package com.example.ecoportapi.Controllers;

import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Services.ConquistaService;
import com.example.ecoportapi.Services.SessaoInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Conquistas.
 *
 * <p>Duas coisas bem diferentes moram aqui, e por isso a divisão é explícita:
 *
 * <ul>
 *   <li>{@code /usuarios/eu/conquistas} — a sua conta. Quem é você vem do
 *   token: antes o progresso vinha por id na URL, o que queria dizer que dava
 *   para desbloquear conquista na conta de qualquer pessoa.</li>
 *   <li>{@code /usuarios/{id}/conquistas} — só leitura, para o perfil de outra
 *   pessoa mostrar o emblema dela. Conquista é parte pública do perfil (o
 *   mesmo que o "nível" e as moedas), mas quem desbloqueia é sempre a própria
 *   conta.</li>
 * </ul>
 */
@RestController
@RequestMapping("/usuarios")
public class ConquistaController {

    private final ConquistaService conquistaService;

    public ConquistaController(ConquistaService conquistaService) {
        this.conquistaService = conquistaService;
    }

    @GetMapping("/eu/conquistas")
    @ExigeSessao
    public ResponseEntity<?> ListarDesbloqueadas(HttpServletRequest request) {
        return ResponseEntity.ok(conquistaService.listarDesbloqueadas(euId(request)));
    }

    @PostMapping("/eu/conquistas/{chave}")
    @ExigeSessao
    public ResponseEntity<?> Desbloquear(
            @PathVariable String chave, HttpServletRequest request) {
        return conquistaService.desbloquear(euId(request), chave);
    }

    /**
     * Conquistas de outra conta: só a lista de quais foram liberadas, nada
     * além. Não exige sessao porque o perfil de alguém é público.
     */
    @GetMapping("/{id}/conquistas")
    public ResponseEntity<?> ConquistasDoUsuario(@PathVariable Long id) {
        return ResponseEntity.ok(conquistaService.listarDesbloqueadas(id));
    }

    private Long euId(HttpServletRequest request) {
        Usuario usuario = SessaoInterceptor.usuarioObrigatorio(request);

        return usuario.getId();
    }
}