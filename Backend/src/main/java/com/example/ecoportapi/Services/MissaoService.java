package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.ProgressoDTO;
import com.example.ecoportapi.DTOs.Response.MissaoDTO;
import com.example.ecoportapi.Exceptions.MissaoJaConcluida;
import com.example.ecoportapi.Exceptions.MissaoNaoEncontrada;
import com.example.ecoportapi.Exceptions.RequisicaoInvalida;
import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Missao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class MissaoService {

    private final MissaoRepository missaoRepository;
    private final UsuarioRepository usuarioRepository;

    public MissaoService(MissaoRepository missaoRepository, UsuarioRepository usuarioRepository) {
        this.missaoRepository = missaoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    public MissaoDTO PegarMissao(Long id){
        return new MissaoDTO(
                missaoRepository.findById(id)
                        .orElseThrow(
                                () -> new MissaoNaoEncontrada("Missão não encontrada"))
        );
    }

    private void entregarRecompensa(Missao missao){
        Usuario usuario = missao.getUsuario();

        usuario.setXP(
                usuario.getXP() + missao.getXpRecompensa()
        );

        if (usuario.getXP() >= 100){
            usuario.setXP(usuario.getXP() - 100);
            usuario.setLevel(usuario.getLevel() + 1);
        }

        usuario.setMoedas(
                usuario.getMoedas() + missao.getMoedaRecompensa()
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
            throw new MissaoJaConcluida("Esta missão foi ou concluida ou esta expirada");
        }

        if (progressoDTO.Progresso() == null || progressoDTO.Progresso() <= 0){
            throw new RequisicaoInvalida("cara eu nem sei oq mais fazer, arruma dps caio");
        }

        missao.setProgresso( missao.getProgresso() + progressoDTO.Progresso() );

        if (missao.getProgresso() >= missao.getMeta()){
            missao.setStatusMissao(StatusMissao.CONCLUIDA);
            entregarRecompensa(missao);
        } else{
            missao.setStatusMissao(StatusMissao.EM_ANDAMENTO);
        }

        missaoRepository.save(missao);
        return new MissaoDTO(missao);
    }

}
