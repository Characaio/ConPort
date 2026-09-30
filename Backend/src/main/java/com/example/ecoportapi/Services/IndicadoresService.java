package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Repositories.ReportRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IndicadoresService {

    private final ReportRepository reportRepository;

    public IndicadoresService(ReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    public UnidadeIndicadoresDTO CalcularIndicadores(
            UnidadeDadosAmbientaisDTO unidadeDadosAmbientais,
            Long unidadeId
    ){
        Integer CorredoresNecessarios = CalcularCorredoresNecessarios(
                unidadeDadosAmbientais.areaTotal(), unidadeDadosAmbientais.areaBasePorCorredor()
        );
        return new UnidadeIndicadoresDTO(
                CalcularIntegridadeTerritorial(
                        unidadeDadosAmbientais.areaRegularizada(), unidadeDadosAmbientais.areaTotal()
                ),
                CorredoresNecessarios,
                CalcularConectividadeEcologica(
                        unidadeDadosAmbientais.quantCorredores(), CorredoresNecessarios
                ),
                CalcularQualidadeAmbiental(
                        unidadeDadosAmbientais.qualidadeAgua(),
                        unidadeDadosAmbientais.qualidadeSolo(),
                        unidadeDadosAmbientais.gestaoResiduos()
                ),
                CalcularPreservacaoLocal(
                        unidadeDadosAmbientais.areaPreservada(), unidadeDadosAmbientais.areaTotal()
                ),
                CalcularFiscalizacao(
                        CalcularCobertura(
                                unidadeDadosAmbientais.areaMonitorada(), unidadeDadosAmbientais.areaTotal()
                        ),
                        CalcularMonitoramento(
                                unidadeDadosAmbientais.pontosMonitorados(), unidadeDadosAmbientais.pontosPrevistos()
                        ),
                        CalcularResposta(
                                reportRepository.PegarReportsConfirmados(
                                        unidadeId,
                                        List.of(
                                                StatusReport.ACEITO,
                                                StatusReport.EM_TRATAMENTO,
                                                StatusReport.TRATADO
                                        )
                                ), reportRepository.PegarReportsTratados(
                                        unidadeId,
                                        StatusReport.TRATADO)
                        )
                ),
                CalcularBiodiversidade(
                        unidadeDadosAmbientais.quantEspecies(), unidadeDadosAmbientais.quantEspeciesEsperadas()
                )
        );
    }
    private Double CalcularIntegridadeTerritorial(Double AreaRegularizada,Double AreaTotal){
        return (AreaRegularizada / AreaTotal) * 100;
    }

    private Double CalcularConectividadeEcologica(int QuantCorredores, Integer QuantCorredoresNecessarios){
        return ((double) QuantCorredores / QuantCorredoresNecessarios) * 100;
    }

    private Double CalcularQualidadeAmbiental(Double QualidadeAgua,Double QualidadeSolo,Double GestaoResiduos){
        return (QualidadeAgua*0.40f + QualidadeSolo*0.35f + GestaoResiduos * 0.25f);
    }

    private Double CalcularPreservacaoLocal(Double AreaPreservada, Double AreaTotal){
        return (AreaPreservada/AreaTotal) * 100f;
    }

    private Double CalcularCobertura(Double AreaFiscalizada,Double AreaTotal){
        return (AreaFiscalizada/AreaTotal) * 100;
    }
    private Double CalcularMonitoramento(Integer PontosMonitorados, Integer PontosPrevistos){
        return  ((double) PontosMonitorados / PontosPrevistos) * 100;
    }
    private Double CalcularResposta(Integer IncidentesConfirmados, Integer IncidenteTratados){
        if (IncidentesConfirmados == 0){
            return 100.0;
        }
        return  ((double) IncidenteTratados/IncidentesConfirmados) * 100;
    }

    private Double CalcularFiscalizacao(Double Cobertura, Double Monitoramento, Double Resposta){
        return (Cobertura*0.40f + Monitoramento*0.30f + Resposta * 0.30f);
    }

    private Double CalcularBiodiversidade(int QuantEspecies,int QuantEspeciesEsperadas){
        return  ((double) QuantEspecies/QuantEspeciesEsperadas) * 100;
    }

    private Integer CalcularCorredoresNecessarios(Double AreaTotal, Double AreaBasePorCorredor){
        return (int) Math.ceil(AreaTotal/AreaBasePorCorredor);
    }

}
