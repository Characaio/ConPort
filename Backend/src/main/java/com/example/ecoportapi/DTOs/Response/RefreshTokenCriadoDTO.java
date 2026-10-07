package com.example.ecoportapi.DTOs.Response;

import com.example.ecoportapi.Models.RefreshToken;

public record RefreshTokenCriadoDTO (
    RefreshToken refreshToken,
    String token
){}
