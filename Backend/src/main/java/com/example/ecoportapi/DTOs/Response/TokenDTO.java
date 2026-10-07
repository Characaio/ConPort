package com.example.ecoportapi.DTOs.Response;

public record TokenDTO(
        String accessToken,
        String refreshToken
) {
}
