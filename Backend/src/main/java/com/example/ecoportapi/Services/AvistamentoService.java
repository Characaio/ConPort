package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AvistamentoCreateDTO;
import com.example.ecoportapi.DTOs.Response.AvistamentoDTO;
import com.example.ecoportapi.Models.Avistamento;
import com.example.ecoportapi.Repositories.AvistamentoRepository;
import org.apache.coyote.Response;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Service
public class AvistamentoService {

    private final AvistamentoRepository avistamentoRepository;

    public AvistamentoService(AvistamentoRepository avistamentoRepository) {
        this.avistamentoRepository = avistamentoRepository;
    }

    public ResponseEntity<?> CriarAvistamento(AvistamentoCreateDTO avistamentoDTO, MultipartFile imagem){
        Avistamento avistamento = new Avistamento();

        avistamento.setLatitude(avistamentoDTO.Latitude());
        avistamento.setLongitude(avistamentoDTO.Longitude());
        avistamento.setHoraDoAvistamento(LocalDateTime.now());

        avistamento.setCerteza(100.0);
        avistamento.setEspecieAvistada("It's a Gamer");

        ExampleMatcher matcher = ExampleMatcher.matching()
                .withIgnorePaths("Id","HoraDoAvistamento");

        Example<Avistamento> example = Example.of(avistamento,matcher);

        if (avistamentoRepository.exists(example    )){
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Avistamento duplicado");
        }

        avistamentoRepository.save(avistamento);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}
