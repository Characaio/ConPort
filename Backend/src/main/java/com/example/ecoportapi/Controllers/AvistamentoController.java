package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.Services.AvistamentoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/avistamento")
public class AvistamentoController {

    private final AvistamentoService avistamentoService;

    public AvistamentoController(AvistamentoService avistamentoService) {
        this.avistamentoService = avistamentoService;
    }

    @PostMapping
    public ResponseEntity<?> CriarAvistamento(
            @RequestBody AvistamentoCreateDTO avistamentoDTO
    ){
        return avistamentoService.CriarAvistamento(avistamentoDTO);
    }
}
