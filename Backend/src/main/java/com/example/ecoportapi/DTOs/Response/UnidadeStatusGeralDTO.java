package com.example.ecoportapi.DTOs.Response;


import com.example.ecoportapi.Models.Enums.TipoDeUnidade;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.time.LocalTime;

public record UnidadeStatusGeralDTO(
        Long Id,
        String Nome,
        String Telefone,
        TipoDeUnidade TipoDeUnidade,
        Integer QuantReports,
        //Essas informações devem ser formatadas como:
        //XX:XX até YY:YY
        //Com X sendo o horario de abertura e Y sendo o horario de fechamento
        //Ambos seguem a formatação e HORA:MINUTO
        LocalTime HoraDeAbertura,
        LocalTime HoraDeFechamento,

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
            UnidadeDadosGeraisDTO base,
            int QuantReports,
            UnidadeIndicadoresDerivadosDTO indicadores){
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

                roundWithBigDecimal(indicadores.IntegridadeTerritorial(),2),
                indicadores.CorredoresNecessarios(),
                roundWithBigDecimal(indicadores.ConectividadeEcologica(),2),
                roundWithBigDecimal(indicadores.QualidadeAmbiental(),2),
                roundWithBigDecimal(indicadores.PreservacaoLocal(),2),
                roundWithBigDecimal(indicadores.Fiscalizacao(),2),
                roundWithBigDecimal(indicadores.Biodiversidade(),2)
        );

    }
    public static double roundWithBigDecimal(double value, int places) {
        if (places < 0) {
            throw new IllegalArgumentException("Decimal places must be non-negative.");
        }
        BigDecimal bd = BigDecimal.valueOf(value);
        bd = bd.setScale(places, RoundingMode.HALF_UP); // HALF_UP is standard rounding
        return bd.doubleValue();
    }
}
