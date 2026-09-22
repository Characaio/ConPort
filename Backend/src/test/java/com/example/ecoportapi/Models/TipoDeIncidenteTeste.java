package com.example.ecoportapi.Models;

import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class TipoDeIncidenteTeste {

    @Test
    void deveConverterStringParaTipoDeIncidente(){

        TipoDeIncidente resultado = TipoDeIncidente.StringParaTipo("Queimada");

        assertEquals(
                TipoDeIncidente.QUEIMADA,
                resultado
        );
    }
}
