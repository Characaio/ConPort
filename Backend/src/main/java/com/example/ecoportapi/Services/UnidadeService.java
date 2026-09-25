package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UnidadeService {

    private final UnidadeRepository unidadeRepository;
    private final ReportRepository reportRepository;
    private final IndicadoresService indicadoresService;

    public UnidadeService(UnidadeRepository unidadeRepository, ReportRepository reportRepository, IndicadoresService indicadoresService) {
        this.unidadeRepository = unidadeRepository;
        this.reportRepository = reportRepository;
        this.indicadoresService = indicadoresService;
    }


    public UnidadeStatusPrincipalDTO PegarStatusPrincipal(Long id){
        UnidadeDadosGeraisDTO StatusGeralBaseDTO = unidadeRepository.PegarStatusGeral(id);
        Integer QuantDeReports = unidadeRepository.PegarQuantDeReports(id);
        UnidadeIndicadoresDerivadosDTO indicadoresDerivadosDTO =
                indicadoresService.CalcularIndicadores(StatusGeralBaseDTO);

        return new UnidadeStatusPrincipalDTO(
                unidadeRepository.PegarStatusPrincipal(id),
                QuantDeReports,
                indicadoresDerivadosDTO);
    }

    public UnidadeStatusGeralDTO PegarStatusGeral(Long id){
        UnidadeDadosGeraisDTO StatusGeralBaseDTO = unidadeRepository.PegarStatusGeral(id);
        Integer QuantDeReports = unidadeRepository.PegarQuantDeReports(id);
        UnidadeIndicadoresDerivadosDTO indicadoresDerivadosDTO =
                indicadoresService.CalcularIndicadores(StatusGeralBaseDTO);

        return new UnidadeStatusGeralDTO(
                StatusGeralBaseDTO,
                QuantDeReports,
                indicadoresDerivadosDTO);
    }

    public List<ReportResumidoDTO> PegarReportsDaUnidade(Long id){
        return unidadeRepository.PegarReportsDaUnidade(id);
    }



}
