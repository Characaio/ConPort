package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.Aviso;
import org.jspecify.annotations.NonNull;

import java.time.LocalDateTime;

public record AvisoResponseDTO(
        Long id,
        String Titutlo,
        String Descricao,
        LocalDateTime HorarioDoAviso,
        Boolean Fixo,
        String Imagem
) {
    public AvisoResponseDTO(@NonNull Aviso aviso){
        this(
                aviso.getId(),
                aviso.getTitulo(),
                aviso.getConteudo(),
                aviso.getHorarioDoAviso(),
                // Aviso antigo, criado antes do campo existir, nao e fixado.
                aviso.getFixo() != null && aviso.getFixo(),
                aviso.getImagem()
        );
    }
}
