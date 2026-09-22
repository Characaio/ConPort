package com.example.ecoportapi.Exceptions;

public class MissaoJaConcluida extends RuntimeException {
    public MissaoJaConcluida(String message) {
        super(message);
    }
}
