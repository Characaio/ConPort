package com.example.ecoportapi.DTOs.Response;


import com.example.ecoportapi.Models.Enums.TipoDeUnidade;

import java.time.LocalTime;

public record UnidadeInformacoesDTO(
        Long Id,
        String Nome,
        String Telefone,
        TipoDeUnidade TipoDeUnidade,
        //Essas informações devem ser formatadas como:
        //XX:XX até YY:YY
        //Com X sendo o horario de abertura e Y sendo o horario de fechamento
        //Ambos seguem a formatação e HORA:MINUTO
        LocalTime HoraDeAbertura,
        LocalTime HoraDeFechamento
) {}
