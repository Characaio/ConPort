package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AvisoCreateDTO;
import com.example.ecoportapi.DTOs.Response.AvisoResponseDTO;
import com.example.ecoportapi.DTOs.Response.MissaoDTO;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Models.Aviso;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Repositories.AvisoRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;


import java.time.LocalDateTime;
import java.util.List;

@Service
public class AvisoService {

    private final UnidadeRepository unidadeRepository;
    private final AvisoRepository avisoRepository;

    public AvisoService(UnidadeRepository unidadeRepository,
                        AvisoRepository avisoRepository) {
        this.unidadeRepository = unidadeRepository;
        this.avisoRepository = avisoRepository;
    }

    public List<AvisoResponseDTO> BuscarAvisos(Long unidadeId, Integer limite){

        Pageable pageable = PageRequest.of(
                0,
                limite,
                Sort.by(Sort.Direction.DESC, "HorarioDoAviso")
        );
        return avisoRepository.findByUnidadeId(unidadeId,pageable)
                .getContent().stream()
                .map(AvisoResponseDTO::new)
                .toList();
    }


    public AvisoResponseDTO PostarAviso(AvisoCreateDTO avisoDTO, Long unidadeId){
        Aviso aviso = new Aviso();
        UnidadeDeConservacao unidade = unidadeRepository.findById(unidadeId)
                .orElseThrow(
                        () -> new UnidadeNaoEncontrada("Unidade não encontrada")
                );

        aviso.setConteudo(avisoDTO.Conteudo());
        aviso.setTitulo(avisoDTO.Titulo());
        aviso.setHorarioDoAviso(LocalDateTime.now());
        aviso.setUnidade(unidade);

        return new AvisoResponseDTO(avisoRepository.save(aviso));
    }
}
