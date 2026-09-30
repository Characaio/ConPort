package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Exceptions.InformacoesNaoEncontrada;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import org.springframework.stereotype.Service;

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


    public UnidadeInformacoesDTO PegarInformacoes(Long unidadeId){
        return new UnidadeInformacoesDTO(
                unidadeRepository.findById(unidadeId).orElseThrow(
                        () -> new InformacoesNaoEncontrada("Informações da unidade não encontrada")
                )
        );
    }

    public UnidadeStatusDTO PegarStatus(Long unidadeId){
        UnidadeDeConservacao unidade = unidadeRepository.findById(unidadeId)
                .orElseThrow(
                        () -> new InformacoesNaoEncontrada("Informações da unidade não encontrada")
                );

        UnidadeInformacoesDTO unidadeInformacoesDTO = new UnidadeInformacoesDTO(unidade);

        UnidadeDadosAmbientaisDTO unidadeDadosAmbientaisDTO = new UnidadeDadosAmbientaisDTO(unidade);

        UnidadeIndicadoresDTO unidadeIndicadoresDTO = indicadoresService
                .CalcularIndicadores(unidadeDadosAmbientaisDTO,unidadeId);

        return new UnidadeStatusDTO(
                unidadeInformacoesDTO,
                unidadeIndicadoresDTO,
                unidadeDadosAmbientaisDTO,
                reportRepository.PegarQuantDeReports(unidadeId)
        );
    }





}
