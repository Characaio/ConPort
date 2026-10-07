package com.example.ecoportapi.Exceptions;

public class TokenInvalido extends RuntimeException {
    public TokenInvalido(String message) {
        super(message);
    }
}
