package com.example.ecoportapi.DTOs.Response;


public record UnidadeStatusPrincipalDTO(
        String Nome,
        String Telefone,
        String TipoDeUnidade,
        Integer QuantReports,
        //Essas informações devem ser formatadas como:
        //XX:XX até YY:YY
        //Com X sendo o horario de abertura e Y sendo o horario de fechamento
        //Ambos seguem a formatação e HORA:MINUTO
        String HoraDeAbertura,
        String HoraDeFechamento,

        Double IntegridadeTerritorial,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        String Fiscalizacao,
        String Biodiversidade
) {
    public UnidadeStatusPrincipalDTO(
            UnidadeStatusPrincipalBaseDTO base,
            int QuantReports,
            IndicadoresDerivadosDTO indicadores){
        this(
                base.Nome(),
                base.Telefone(),
                base.TipoDeUnidade(),
                QuantReports,

                base.HoraDeAbertura(),
                base.HoraDeFechamento(),

                indicadores.IntegridadeTerritorial(),
                indicadores.ConectividadeEcologica(),
                indicadores.QualidadeAmbiental(),
                indicadores.PreservacaoLocal(),
                PorcentagemParaString(indicadores.Fiscalizacao()),
                PorcentagemParaString(indicadores.Biodiversidade())
        );
    }
    public static String PorcentagemParaString(Double porcentagem){
        String resultado = "";
        if (porcentagem >= 0 && porcentagem <= 33.3){
            resultado = "Baixo";
        } else if (porcentagem > 33.3 && porcentagem <= 66.6){
            resultado = "Medio";
        } else {
            resultado = "Alto";
        }
        return resultado;
    }
}
