package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.DTOs.Response.AvistamentoDTO;
import com.example.ecoportapi.Exceptions.AvistamentoNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Avistamento;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.AvistamentoRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.apache.coyote.Response;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class AvistamentoService {

    private final AvistamentoRepository avistamentoRepository;
    private final UnidadeRepository unidadeRepository;
    private final UsuarioRepository usuarioRepository;
    private final ImagemService imagemService;

    public AvistamentoService(
            AvistamentoRepository avistamentoRepository,
            UnidadeRepository unidadeRepository,
            UsuarioRepository usuarioRepository,
            ImagemService imagemService) {
        this.avistamentoRepository = avistamentoRepository;
        this.unidadeRepository = unidadeRepository;
        this.usuarioRepository = usuarioRepository;
        this.imagemService = imagemService;
    }

    public ResponseEntity<?> CriarAvistamento(
            AvistamentoCreateDTO avistamentoDTO,
            MultipartFile imagem,
            Long unidadeId) throws IOException {
        Avistamento avistamento = new Avistamento();

              Usuario usuario = usuarioRepository.findById(
                avistamentoDTO.UsuarioId()
            ).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuario não encontrado")
            );
              UnidadeDeConservacao unidade = unidadeRepository.findById(
                unidadeId
            ).orElseThrow(
                () -> new UnidadeNaoEncontrada("Unidade não encontrada")
            );

        ImagemProcessada imagemAnexada = imagemService.SalvarImagem(imagem);
        avistamento.setImagemAnexada(imagemAnexada.NomeArquivo());

        if (avistamentoDTO.Latitude() == null && avistamentoDTO.Longitude() == null){
            avistamento.setLatitude(imagemAnexada.Latitude());
            avistamento.setLongitude(imagemAnexada.Longitude());
        } else{
            avistamento.setLatitude(avistamentoDTO.Latitude());
            avistamento.setLongitude(avistamentoDTO.Longitude());
        }
        avistamento.setHoraDoAvistamento(LocalDateTime.now());

        avistamento.setUsuario(usuario);
        avistamento.setUnidade(unidade);

        avistamento.setCerteza(100.0);
        avistamento.setEspecieAvistada("It's a Gamer");

        avistamentoRepository.save(avistamento);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    public AvistamentoDTO PegarAvistamento(Long avistamentoId){
        return new AvistamentoDTO(
                avistamentoRepository.findById(avistamentoId)
                        .orElseThrow(() -> new AvistamentoNaoEncontrado("Avistamento Não encontrado")
                        )
        );
    }

    //METODO AINDA NÃO UTILIZADO, UTILIZAR AO CRIAR A LOGICA DE USUARIO VER SUAS COISAS
    public List<AvistamentoDTO> PegarAvistamentosDoUsaurio(Long usuarioId){
        return avistamentoRepository.listarDoUsuario(usuarioId)
                .stream().map(AvistamentoDTO::new)
                .toList();
    }

    public List<AvistamentoDTO> PegarAvistamentosDaUnidade(Long unidadeId){
        return avistamentoRepository.listarDaUnidade(unidadeId)
                .stream().map(AvistamentoDTO::new)
                .toList();
    }

}
