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

    @ExceptionHandler(MissaoJaConcluida.class)
    public ResponseEntity<String> MissaoJaConcluida(MissaoJaConcluida exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(MissaoNaoEncontrada.class)
    public ResponseEntity<String> MissaoNaoEncontrada(MissaoNaoEncontrada exception){
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

    @ExceptionHandler(RequisicaoInvalida.class)
    public ResponseEntity<String> RequisicaoInvalida(RequisicaoInvalida exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body("Eu tenho q trabalhar melhor nisso aqui, ta merda gamer" + exception.getMessage() + "\n" + exception.getStackTrace());
    }

    @ExceptionHandler(UsuarioNaoEncontrado.class)
    public ResponseEntity<String> UsuarioNaoEncontrado(UsuarioNaoEncontrado exception){
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

    /*
    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<String> NullPointerException(NullPointerException exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }
    */

    @ExceptionHandler(IOException.class)
    public ResponseEntity<String> IOException(IOException exception){
        erroLoggerService.registrarErro(exception);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(exception.getMessage() + "\n" + exception.getStackTrace());
    }

}
