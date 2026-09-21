package com.example.ecoportapi.DTOs.Response;


public record UnidadeStatusPrincipalBaseDTO(
        Long Id,
        String Nome,
        String Telefone,
        String TipoDeUnidade,
        //Essas informações devem ser formatadas como:
        //XX:XX até YY:YY
        //Com X sendo o horario de abertura e Y sendo o horario de fechamento
        //Ambos seguem a formatação e HORA:MINUTO
        String HoraDeAbertura,
        String HoraDeFechamento
) {}
