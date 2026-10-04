package com.example.ecoportapi.Config;

import com.example.ecoportapi.Services.SessaoInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

  private final SessaoInterceptor sessaoInterceptor;

  public WebConfig(SessaoInterceptor sessaoInterceptor) {
    this.sessaoInterceptor = sessaoInterceptor;
  }

  /**
   * Vale para tudo, e não só para as rotas autenticadas: as públicas também
   * precisam saber se há alguém logado (é o que faz o perfil de um terceiro
   * mostrar "Seguindo" em vez de "Seguir").
   */
  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(sessaoInterceptor).addPathPatterns("/**");
  }
}
