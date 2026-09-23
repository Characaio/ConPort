package com.example.ecoportapi.Services;

import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import org.springframework.stereotype.Service;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.Repositories.UsuarioRepository;

@Service
public class UsuarioService {

    private UsuarioRepository usuarioRepository;
    private MissaoRepository missaoRepository;
    public UsuarioService(UsuarioRepository usuarioRepository, MissaoRepository missaoRepository){
        this.usuarioRepository = usuarioRepository;
        this.missaoRepository = missaoRepository;
    }

    public UsuarioDTO pegarUsuario(Long usuarioId){
        Integer reportsEnviados = Math.toIntExact(usuarioRepository.countReportsEnviados(usuarioId));
        Integer reportsResolvidos = Math.toIntExact(usuarioRepository.countReportsByStatus(
                usuarioId,
                StatusReport.TRATADO
        ));

        Integer reportsRejeitados = Math.toIntExact(usuarioRepository.countReportsByStatus(
                usuarioId,
                StatusReport.NEGADO
        ));

        Integer reportsPendentes = Math.toIntExact(usuarioRepository.countReportsByStatus(
                usuarioId,
                StatusReport.PENDENTE
        ));

        Integer missoesConcluidas = missaoRepository.countMissoesConcluidas(
                usuarioId,
                StatusMissao.CONCLUIDA);

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(

                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );

        return new UsuarioDTO(
                usuario,
                reportsEnviados,reportsResolvidos,
                reportsRejeitados,reportsPendentes, missoesConcluidas);

    }
}
