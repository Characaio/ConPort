package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.DTOs.Response.AvistamentoDTO;
import com.example.ecoportapi.Repositories.AvistamentoRepository;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class AvistamentoService {

    private final AvistamentoRepository avistamentoRepository;

    public AvistamentoService(AvistamentoRepository avistamentoRepository) {
        this.avistamentoRepository = avistamentoRepository;
    }

    public ResponseEntity<?> CriarAvistamento(AvistamentoCreateDTO avistamentoDTO){
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}
