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

    private IndicadoresDerivadosDTO CalcularIndicadores(UnidadeStatusGeralBaseDTO StatusGeralBaseDTO){
        Integer CorredoresNecessarios = indicadoresService.CalcularCorredoresNecessarios(
                StatusGeralBaseDTO.AreaTotal(),StatusGeralBaseDTO.AreaBasePorCorredor()
        );
        IndicadoresDerivadosDTO indicadoresDerivadosDTO = new IndicadoresDerivadosDTO(
                indicadoresService.CalcularIntegridadeTerritorial(
                        StatusGeralBaseDTO.AreaRegularizada(),StatusGeralBaseDTO.AreaTotal()
                ),
                CorredoresNecessarios,
                indicadoresService.CalcularConectividadeEcologica(
                        StatusGeralBaseDTO.QuantCorredores(),CorredoresNecessarios
                ),
                indicadoresService.CalcularQualidadeAmbiental(
                        StatusGeralBaseDTO.QualidadeAgua(),
                        StatusGeralBaseDTO.QualidadeSolo(),
                        StatusGeralBaseDTO.GestaoResiduos()
                ),
                indicadoresService.CalcularPreservacaoLocal(
                        StatusGeralBaseDTO.AreaPreservada(),StatusGeralBaseDTO.AreaTotal()
                ),
                indicadoresService.CalcularFiscalizacao(
                        indicadoresService.CalcularCobertura(
                                StatusGeralBaseDTO.AreaMonitorada(),StatusGeralBaseDTO.AreaTotal()
                        ),
                        indicadoresService.CalcularMonitoramento(
                                StatusGeralBaseDTO.PontosMonitorados(),StatusGeralBaseDTO.PontosPrevistos()
                        ),
                        indicadoresService.CalcularResposta(
                                reportRepository.PegarReportsConfirmados(
                                        StatusGeralBaseDTO.Id(),
                                        List.of(
                                                StatusReport.ACEITO,
                                                StatusReport.EM_TRATAMENTO,
                                                StatusReport.TRATADO
                                        )
                                ), reportRepository.PegarReportsTratados(
                                        StatusGeralBaseDTO.Id(),
                                        StatusReport.TRATADO)
                        )
                ),
                indicadoresService.CalcularBiodiversidade(
                        StatusGeralBaseDTO.QuantEspecies(),StatusGeralBaseDTO.QuantEspeciesEsperadas()
                )
        );
        return indicadoresDerivadosDTO;
    }

    public UnidadeStatusPrincipalDTO PegarStatusPrincipal(Long id){
        UnidadeStatusGeralBaseDTO StatusGeralBaseDTO = unidadeRepository.PegarStatusGeral(id);
        Integer QuantDeReports = unidadeRepository.PegarQuantDeReports(id);
        IndicadoresDerivadosDTO indicadoresDerivadosDTO = CalcularIndicadores(StatusGeralBaseDTO);

        return new UnidadeStatusPrincipalDTO(
                unidadeRepository.PegarStatusPrincipal(id),
                QuantDeReports,
                indicadoresDerivadosDTO);
    }

    public UnidadeStatusGeralDTO PegarStatusGeral(Long id){
        UnidadeStatusGeralBaseDTO StatusGeralBaseDTO = unidadeRepository.PegarStatusGeral(id);
        Integer QuantDeReports = unidadeRepository.PegarQuantDeReports(id);
        IndicadoresDerivadosDTO indicadoresDerivadosDTO = CalcularIndicadores(StatusGeralBaseDTO);

        return new UnidadeStatusGeralDTO(
                StatusGeralBaseDTO,
                QuantDeReports,
                indicadoresDerivadosDTO);
    }

    public List<ReportResumidoDTO> PegarReportsDaUnidade(Long id){
        return unidadeRepository.PegarReportsDaUnidade(id);
    }

}
