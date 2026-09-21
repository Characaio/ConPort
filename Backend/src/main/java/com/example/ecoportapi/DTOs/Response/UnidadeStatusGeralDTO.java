package com.example.ecoportapi.DTOs.Response;


public record UnidadeStatusGeralDTO(
        Long Id,
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

        Double AreaTotal,
        Double AreaRegularizada,
        Double AreaPreservada,
        Double AreaMonitorada,
        Double AreaBasePorCorredor,
        Integer PontosMonitorados,
        Integer PontosPrevistos,

        Integer QuantCorredores,
        Integer QuantEspecies,
        Integer QuantEspeciesEsperadas,
        Double QualidadeAgua,
        Double QualidadeSolo,
        Double GestaoResiduos,

        Double IntegridadeTerritorial,
        Integer CorredoresNecessarios,
        Double ConectividadeEcologica,
        Double QualidadeAmbiental,
        Double PreservacaoLocal,
        Double Fiscalizacao,
        Double Biodiversidade
) {
    public UnidadeStatusGeralDTO(
            UnidadeStatusGeralBaseDTO base,
            int QuantReports,
            IndicadoresDerivadosDTO indicadores){
        this(
                base.Id(),
                base.Nome(),
                base.Telefone(),
                base.TipoDeUnidade(),
                QuantReports,

                base.HoraDeAbertura(),
                base.HoraDeFechamento(),

                base.AreaTotal(),
                base.AreaRegularizada(),
                base.AreaPreservada(),
                base.AreaMonitorada(),
                base.AreaBasePorCorredor(),

                base.PontosMonitorados(),
                base.PontosPrevistos(),

                base.QuantCorredores(),

                base.QuantEspecies(),
                base.QuantEspeciesEsperadas(),

                base.QualidadeAgua(),
                base.QualidadeSolo(),
                base.GestaoResiduos(),

                indicadores.IntegridadeTerritorial(),
                indicadores.CorredoresNecessarios(),
                indicadores.ConectividadeEcologica(),
                indicadores.QualidadeAmbiental(),
                indicadores.PreservacaoLocal(),
                indicadores.Fiscalizacao(),
                indicadores.Biodiversidade()
        );

    }

}
