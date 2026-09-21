package com.example.ecoportapi.Services;

import org.springframework.stereotype.Service;

@Service
public class IndicadoresService {

    public Double CalcularIntegridadeTerritorial(Double AreaRegularizada,Double AreaTotal){
        return (AreaRegularizada/AreaTotal)/100f;
    }

    public Double CalcularConectividadeEcologica(int QuantCorredores, Integer QuantCorredoresNecessarios){
        return (double) ((QuantCorredores/QuantCorredoresNecessarios) * 100f);
    }

    public Double CalcularQualidadeAmbiental(Double QualidadeAgua,Double QualidadeSolo,Double GestaoResiduos){
        return (QualidadeAgua*0.40f + QualidadeSolo*0.35f + GestaoResiduos * 0.25f);
    }

    public Double CalcularPreservacaoLocal(Double AreaPreservada, Double AreaTotal){
        return (AreaPreservada/AreaTotal) * 100f;
    }

    public Double CalcularCobertura(Double AreaFiscalizada,Double AreaTotal){
        return (AreaFiscalizada/AreaTotal) * 100;
    }
    public Double CalcularMonitoramento(Integer PontosMonitorados, Integer PontosPrevistos){
        return (double) ((PontosMonitorados/PontosPrevistos) * 100f);
    }
    public Double CalcularResposta(Integer IncidentesConfirmados, Integer IncidenteTratados){
        return (double) ((IncidenteTratados/IncidentesConfirmados) * 100f);
    }

    public Double CalcularFiscalizacao(Double Cobertura, Double Monitoramento, Double Resposta){
        return (Cobertura*0.40f + Monitoramento*0.30f + Resposta * 0.30f);
    }

    public Double CalcularBiodiversidade(int QuantEspecies,int QuantEspeciesEsperadas){
        return (double) ((QuantEspecies/QuantEspeciesEsperadas) * 100f);
    }

    public Integer CalcularCorredoresNecessarios(Double AreaTotal, Double AreaBasePorCorredor){
        return (int) Math.ceil(AreaTotal/AreaBasePorCorredor);
    }

}
