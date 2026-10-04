package com.example.ecoportapi.Exceptions;

/**
 * E-mail ou senha errados no login, ou senha atual errada na troca.
 *
 * <p>Existe separada do [UsuarioNaoEncontrado] porque as duas situações
 * devem responder a mesma coisa: se "e-mail não existe" devolvesse 404 e
 * "senha errada" devolvesse 401, dava para descobrir quem tem conta no app
 * só olhando o status.
 */
public class CredenciaisInvalidas extends RuntimeException {

  public CredenciaisInvalidas(String message) {
    super(message);
  }
}
