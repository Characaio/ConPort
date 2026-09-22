package com.example.ecoportapi.Exceptions;

import com.example.ecoportapi.Services.ErroLoggerService;
import org.apache.coyote.Response;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.io.IOException;


@RestControllerAdvice
public class GlobalExceptionHandler {

    private final ErroLoggerService erroLoggerService;

    public GlobalExceptionHandler(ErroLoggerService erroLoggerService) {
        this.erroLoggerService = erroLoggerService;
    }


    @ExceptionHandler(UsuarioNaoEncontrado.class)
    public ResponseEntity<String> UsuarioNaoEncontrado(UsuarioNaoEncontrado exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(ReportNaoEncontrado.class)
    public ResponseEntity<String> ReportNaoEncontrado(UsuarioNaoEncontrado exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(UnidadeNaoEncontrada.class)
    public ResponseEntity<String> UnidadeNaoEncontrada(UnidadeNaoEncontrada exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(SupervisorNaoEncontrado.class)
    public ResponseEntity<String> SupervisorNaoEncontrado(SupervisorNaoEncontrado exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> IllegalArgumentException(IllegalArgumentException exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<String> NullPointerException(NullPointerException exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(IOException.class)
    public ResponseEntity<String> IOException(IOException exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

}
