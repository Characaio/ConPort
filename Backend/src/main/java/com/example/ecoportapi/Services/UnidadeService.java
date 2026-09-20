package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusGeralDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusPrincipalDTO;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UnidadeService {

    private final UnidadeRepository unidadeRepository;

    public UnidadeService(UnidadeRepository unidadeRepository) {
        this.unidadeRepository = unidadeRepository;
    }


    public UnidadeStatusPrincipalDTO PegarStatusPrincipal(Long id){
        return unidadeRepository.PegarStatusPrincipal(id);
    }

    public UnidadeStatusGeralDTO PegarStatusGeral(Long id){
        return unidadeRepository.PegarStatusGeral(id);
    }

    public List<ReportResumidoDTO> PegarReportsDaUnidade(Long id){
        return unidadeRepository.PegarReportsDaUnidade(id);
    }
}
