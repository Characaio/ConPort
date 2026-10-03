package com.example.ecoportapi.DTOs.Request;

import java.time.LocalDate;

public record SignupDTO(
        String nome,
        String apelido,
        LocalDate dataNasc,
        String email,
        String senha,
        String estado,
        String cidade
) {}
