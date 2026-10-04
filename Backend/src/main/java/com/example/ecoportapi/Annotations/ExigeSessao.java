package com.example.ecoportapi.Annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Marca um método (ou a classe inteira) como rota autenticada.
 *
 * <p>Sem token válido a resposta é 401, e o usuário da requisição vem do
 * token — nunca da URL. É assim que o id na URL deixa de ser confiável.
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ExigeSessao {}
