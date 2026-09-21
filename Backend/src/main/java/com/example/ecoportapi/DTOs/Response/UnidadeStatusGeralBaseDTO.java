package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.DTOs.Response.IndicadoresDerivadosDTO;

public record UnidadeStatusGeralBaseDTO(
        Long Id,
        String Nome,
        String Localizacao,
        String Bioma,
        String Telefone,
        //Essas informações devem ser formatadas como:
        //XX:XX até YY:YY
        //Com X sendo o horario de abertura e Y sendo o horario de fechamento
        //Ambos seguem a formatação e HORA:MINUTO
        String HoraDeAbertura,
        String HoraDeFechamento,
        String TipoDeUnidade,

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
        Double GestaoResiduos

) {}
