package com.example.ecoportapi.Services;

import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.ConquistaDesbloqueada;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.ConquistaDesbloqueadaRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

/**
 * Conquistas desbloqueadas pelo usuário.
 *
 * As chaves são as do app (report_enviado, avistamento_enviado,
 * recompensa_resgatada, video_assistido, amigo_adicionado). O backend só
 * valida que a chave é conhecida; a lista completa e os títulos ficam no
 * app, que é quem decide o que já foi desbloqueado.
 */
@Service
public class ConquistaService {

    /** Chaves que o app conhece. */
    private static final Set<String> CHAVES_CONHECIDAS = Set.of(
            "report_enviado",
            "avistamento_enviado",
            "recompensa_resgatada",
            "video_assistido",
            "amigo_adicionado"
    );

    private final ConquistaDesbloqueadaRepository conquistaRepository;
    private final UsuarioRepository usuarioRepository;

    public ConquistaService(
            ConquistaDesbloqueadaRepository conquistaRepository,
            UsuarioRepository usuarioRepository
    ) {
        this.conquistaRepository = conquistaRepository;
        this.usuarioRepository = usuarioRepository;
    }

    /** Chaves já desbloqueadas, na ordem em que foram conquistadas. */
    public List<String> listarDesbloqueadas(Long usuarioId) {
        // Sem a lista nao ha usuario: 404 em vez de lista vazia.
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        return conquistaRepository.listarDoUsuario(usuarioId)
                .stream().map(ConquistaDesbloqueada::getChave).toList();
    }

    /**
     * Desbloqueia uma conquista.
     *
     * 201 quando é nova e 409 quando já estava desbloqueada — o app trata o
     * 409 como "ok", porque desbloquear duas vezes não é erro.
     */
    public ResponseEntity<?> desbloquear(Long usuarioId, String chave) {
        Usuario usuario = usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        if (!CHAVES_CONHECIDAS.contains(chave)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                    "Conquista desconhecida: " + chave
            );
        }

        if (conquistaRepository.contarDoUsuarioComChave(usuarioId, chave) > 0) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(
                    "Conquista já desbloqueada"
            );
        }

        conquistaRepository.save(new ConquistaDesbloqueada(usuario, chave));

        return ResponseEntity.status(HttpStatus.CREATED).body(chave);
    }
}