package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.NotificacaoCreateDTO;
import com.example.ecoportapi.DTOs.Response.NotificacaoResponseDTO;
import com.example.ecoportapi.Exceptions.NotificacaoNaoEncontrada;
import com.example.ecoportapi.Exceptions.RequisicaoInvalida;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Notificacao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.NotificacaoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * Notificações de um usuário.
 *
 * O conteúdo da notificação é definido pelo app (conquista liberada, missão
 * concluída, aviso da unidade). O backend guarda, lista e controla o "lida" —
 * que precisa ficar aqui para o sino do topo da tela continuar certo depois
 * que o app fecha.
 *
 * Todas as operações recebem o usuarioId da URL. Sem token no projeto ainda
 * (mesma limitação de ConquistaService e MissaoController), a checagem de
 * dono é feita no WHERE das queries, e não só na URL.
 */
@Service
public class NotificacaoService {

    /** Evita gravar notificação de kilometers de texto sem sentido. */
    private static final int TAMANHO_MAXIMO_TEXTO = 1000;

    private final NotificacaoRepository notificacaoRepository;
    private final UsuarioRepository usuarioRepository;

    public NotificacaoService(
            NotificacaoRepository notificacaoRepository,
            UsuarioRepository usuarioRepository
    ) {
        this.notificacaoRepository = notificacaoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    /**
     * Todas as notificações do usuário, da mais recente para a mais antiga.
     */
    public List<NotificacaoResponseDTO> listar(Long usuarioId) {
        // Sem a lista não há usuário: 404 em vez de lista vazia, que o app
        // leria como "não tem notificação".
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        return notificacaoRepository.listarDoUsuario(usuarioId)
                .stream().map(NotificacaoResponseDTO::new).toList();
    }

    /**
     * Só as não lidas — o que o sino do topo da tela mostra.
     */
    public List<NotificacaoResponseDTO> listarNaoLidas(Long usuarioId) {
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        return notificacaoRepository.listarNaoLidasDoUsuario(usuarioId)
                .stream().map(NotificacaoResponseDTO::new).toList();
    }

    /**
     * Quantas não lidas existem.
     *
     * Separado da lista porque o badge é polled com frequência e não precisa
     * baixar título e texto de cada notificação para desenhar só um número.
     */
    public Map<String, Object> contarNaoLidas(Long usuarioId) {
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        return Map.of("naoLidas", notificacaoRepository.contarNaoLidasDoUsuario(usuarioId));
    }

    /**
     * Cria uma notificação para um usuario, sem passar pelo DTO.
     *
     * <p>Usado pelo proprio backend quando o evento ja aconteceu aqui dentro
     * (cadastro, solicitação de amizade, amizade aceita). O texto vem escrito
     * pelo servidor porque é ele quem tem os dois lados do evento — o app, no
     * caso da amizade, nem está com a outra pessoa aberta.
     */
    public NotificacaoResponseDTO avisar(Usuario usuario, String titulo, String texto) {
        if (usuario == null) {
            return null;
        }

        if (texto == null || texto.isBlank()) {
            return null;
        }

        String textoLimpo = texto.trim();

        if (textoLimpo.length() > TAMANHO_MAXIMO_TEXTO) {
            textoLimpo = textoLimpo.substring(0, TAMANHO_MAXIMO_TEXTO);
        }

        return new NotificacaoResponseDTO(
                notificacaoRepository.save(
                        new Notificacao(usuario, titulo.trim(), textoLimpo)
                )
        );
    }

    /**
     * Cria uma notificação para o usuário da URL.
     */
    public NotificacaoResponseDTO criar(Long usuarioId, NotificacaoCreateDTO dto) {
        if (dto == null || dto.titulo() == null || dto.titulo().isBlank()) {
            throw new RequisicaoInvalida("O título da notificação é obrigatório.");
        }

        if (dto.texto() == null || dto.texto().isBlank()) {
            throw new RequisicaoInvalida("O texto da notificação é obrigatório.");
        }

        if (dto.texto().length() > TAMANHO_MAXIMO_TEXTO) {
            throw new RequisicaoInvalida(
                    "O texto da notificação passa de " + TAMANHO_MAXIMO_TEXTO + " caracteres."
            );
        }

        Usuario usuario = usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        Notificacao notificacao = new Notificacao(
                usuario,
                dto.titulo().trim(),
                dto.texto().trim()
        );

        return new NotificacaoResponseDTO(notificacaoRepository.save(notificacao));
    }

    /**
     * Marca uma notificação como lida.
     *
     * Idempotente: marcar duas vezes devolve a mesma notificação, sem erro —
     * o app pode tocar na notificação já lida sem tratar o caso separado.
     */
    @Transactional
    public NotificacaoResponseDTO marcarComoLida(Long usuarioId, Long notificacaoId) {
        Notificacao notificacao = buscarDoUsuario(usuarioId, notificacaoId);

        // Só grava quando mudou, para não sujar a data de alteração sempre
        // que o app reenviar.
        if (!Boolean.TRUE.equals(notificacao.getLida())) {
            notificacao.setLida(true);
            notificacaoRepository.save(notificacao);
        }

        return new NotificacaoResponseDTO(notificacao);
    }

    /**
     * Marca todas as não lidas do usuário como lidas.
     *
     * Devolve o total atualizado de não lidas, que é o que o badge mostra
     * depois do "marcar todas".
     */
    @Transactional
    public Map<String, Object> marcarTodasComoLidas(Long usuarioId) {
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuário não encontrado")
        );

        int alteradas = notificacaoRepository.marcarTodasComoLidas(usuarioId);

        return Map.of(
                "marcadas", alteradas,
                "naoLidas", 0L
        );
    }

    /**
     * Exclui uma notificação.
     *
     * Não existe nenhum outro DELETE na API hoje, então este é o primeiro —
     * ver a observação no relatório sobre o padrão do projeto.
     */
    @Transactional
    public void excluir(Long usuarioId, Long notificacaoId) {
        Notificacao notificacao = buscarDoUsuario(usuarioId, notificacaoId);

        notificacaoRepository.delete(notificacao);
    }

    /**
     * Notificação pelo id, garantindo que é do usuário da URL.
     *
     * Centraliza o 404 para não repetir a mesma busca (e a mesma checagem de
     * dono) em marcarComoLida e excluir.
     */
    private Notificacao buscarDoUsuario(Long usuarioId, Long notificacaoId) {
        return notificacaoRepository.buscarDoUsuario(usuarioId, notificacaoId)
                .orElseThrow(() -> new NotificacaoNaoEncontrada(
                        "Notificação " + notificacaoId + " não encontrada."
                ));
    }
}
