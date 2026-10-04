package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.ProgressoDTO;
import com.example.ecoportapi.DTOs.Response.MissaoDTO;
import com.example.ecoportapi.Exceptions.MissaoJaConcluida;
import com.example.ecoportapi.Exceptions.MissaoNaoEncontrada;
import com.example.ecoportapi.Exceptions.RequisicaoInvalida;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Missao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MissaoService {

    /** XP necessário para subir de nível. */
    private static final int XP_POR_NIVEL = 100;

    private final MissaoRepository missaoRepository;
    private final UsuarioRepository usuarioRepository;

    public MissaoService(MissaoRepository missaoRepository, UsuarioRepository usuarioRepository) {
        this.missaoRepository = missaoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    public List<MissaoDTO> listarMissoes(Long usuarioId){
        // Sem a missão não há usuário: garante 404 em vez de lista vazia.
        usuarioRepository.findById(usuarioId).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuario não encontrado")
        );

        return missaoRepository.listarDoUsuario(usuarioId).stream()
                .map(MissaoDTO::new)
                .toList();
    }

    public MissaoDTO PegarMissao(Long id){
        return new MissaoDTO(
                missaoRepository.findById(id)
                        .orElseThrow(
                                () -> new MissaoNaoEncontrada("Missão não encontrada"))
        );
    }

    private void entregarRecompensa(Missao missao){
        Usuario usuario = usuarioRepository.findById(missao.getUsuario().getId())
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado"));

        usuario.setXP(
                (usuario.getXP() == null ? 0 : usuario.getXP())
                        + missao.getXpRecompensa()
        );

        while (usuario.getXP() >= XP_POR_NIVEL){
            usuario.setXP(usuario.getXP() - XP_POR_NIVEL);
            usuario.setLevel((usuario.getLevel() == null ? 0 : usuario.getLevel()) + 1);
        }

        usuario.setMoedas(
                (usuario.getMoedas() == null ? 0 : usuario.getMoedas())
                        + missao.getMoedaRecompensa()
        );

        usuarioRepository.save(usuario);
    }

    @Transactional
    public MissaoDTO ProgredirMissao(Long id, ProgressoDTO progressoDTO){
        Missao missao = missaoRepository.findById(id).orElseThrow(
                () -> new MissaoNaoEncontrada("Missão não encontrada")
        );

        if (missao.getStatusMissao() == StatusMissao.CONCLUIDA ||
                missao.getStatusMissao() == StatusMissao.EXPIRADA){
            throw new MissaoJaConcluida("Esta missão já foi concluída ou está expirada");
        }

        if (progressoDTO == null ||
                progressoDTO.Progresso() == null ||
                progressoDTO.Progresso() <= 0){
            throw new RequisicaoInvalida("O progresso precisa ser maior que zero");
        }

        missao.setProgresso(missao.getProgresso() + progressoDTO.Progresso());

        if (missao.getProgresso() >= missao.getMeta()){
            missao.setStatusMissao(StatusMissao.CONCLUIDA);
            entregarRecompensa(missao);
        } else {
            missao.setStatusMissao(StatusMissao.EM_ANDAMENTO);
        }

        missaoRepository.save(missao);
        return new MissaoDTO(missao);
    }

}