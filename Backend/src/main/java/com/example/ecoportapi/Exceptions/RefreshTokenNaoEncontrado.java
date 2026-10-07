package com.example.ecoportapi.Exceptions;

public class RefreshTokenNaoEncontrado extends RuntimeException {
    public RefreshTokenNaoEncontrado(String message) {
        super(message);
    }
}
