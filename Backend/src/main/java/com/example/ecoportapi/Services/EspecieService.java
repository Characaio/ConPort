package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Response.EspecieDTO;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Models.Enums.TipoEspecie;
import com.example.ecoportapi.Repositories.EspecieRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EspecieService {

    private final EspecieRepository especieRepository;
    private final UnidadeRepository unidadeRepository;

    public EspecieService(
            EspecieRepository especieRepository,
            UnidadeRepository unidadeRepository
    ) {
        this.especieRepository = especieRepository;
        this.unidadeRepository = unidadeRepository;
    }

    /** Especies de um tipo (fauna ou flora) registradas na unidade. */
    public List<EspecieDTO> listar(Long unidadeId, TipoEspecie tipo) {
        // Sem a lista nao ha unidade: 404 em vez de lista vazia.
        unidadeRepository.findById(unidadeId).orElseThrow(
                () -> new UnidadeNaoEncontrada("Unidade não encontrada")
        );

        return especieRepository.listarDaUnidade(unidadeId, tipo)
                .stream().map(EspecieDTO::new).toList();
    }
}