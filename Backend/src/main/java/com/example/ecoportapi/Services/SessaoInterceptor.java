package com.example.ecoportapi.Services;

import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.Models.Usuario;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Resolve o token do header e barra rota autenticada sem sessão.
 *
 * <p>Funciona em toda requisição, mesmo nas rotas públicas: é aí que se
 * descobre se há alguém logado, para o perfil de um terceiro saber se mostra
 * "Seguindo" ou não. Nas marcadas com {@link ExigeSessao}, sem token válido a
 * resposta é 401 antes de o controller rodar.
 */
@Component
public class SessaoInterceptor implements HandlerInterceptor {

  /** Nome dos atributos que o controller vai ler. */
  public static final String ATRIBUTO_TOKEN = "conport.token";

  public static final String ATRIBUTO_USUARIO = "conport.usuario";

  private static final String PREFIXO = "Bearer ";

  private final TokenService tokenService;

  public SessaoInterceptor(TokenService tokenService) {
    this.tokenService = tokenService;
  }

  @Override
  public boolean preHandle(
      HttpServletRequest request, HttpServletResponse response, Object handler) {

    // CORS faz o navegador mandar OPTIONS antes de qualquer rota real.
    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
      return true;
    }

    String token = extrairToken(request);

    if (token != null) {
      Optional<Usuario> usuario = tokenService.usuarioDoToken(token);

      // Token veio mas não vale (expirado, revogado): trata como ausente e
      // deixa a rota pública passar. Quem exige sessão leva 401.
      if (usuario.isPresent()) {
        request.setAttribute(ATRIBUTO_TOKEN, token);
        request.setAttribute(ATRIBUTO_USUARIO, usuario.get());
      }
    }

    if (exigeSessao(handler)) {
      if (usuarioDaRequisicao(request) == null) {
        negarSemSessao(response);
        return false;
      }
    }

    return true;
  }

  /**
   * 401 com corpo JSON.
   *
   * <p>O writer pode lançar IOException (cliente desligou antes de receber),
   * e isso não pode virar 500: quem caiu fora daqui é o interceptor.
   */
  private void negarSemSessao(HttpServletResponse response) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    response.setContentType("application/json;charset=UTF-8");

    try {
      response.getWriter().write("{\"mensagem\":\"Sessão expirada. Entre de novo.\"}");
    } catch (IOException e) {
      // Cliente foi embora antes de ler; o 401 ja foi enviado.
    }
  }

  private boolean exigeSessao(Object handler) {
    if (!(handler instanceof HandlerMethod metodo)) {
      return false;
    }

    return metodo.hasMethodAnnotation(ExigeSessao.class)
        || metodo.getBeanType().isAnnotationPresent(ExigeSessao.class);
  }

  /** Lê o token do header, aceitando só o formato {@code Bearer}. */
  private String extrairToken(HttpServletRequest request) {
    String header = request.getHeader("Authorization");

    if (header == null || !header.startsWith(PREFIXO)) {
      return null;
    }

    String token = header.substring(PREFIXO.length()).trim();

    return token.isEmpty() ? null : token;
  }

  // ============================================================
  // LEITURA PELO CONTROLLER
  // ============================================================

  /** Usuário logado, ou `null` em rota pública sem sessão. */
  public static Usuario usuarioDaRequisicao(HttpServletRequest request) {
    Object usuario = request.getAttribute(ATRIBUTO_USUARIO);

    return usuario instanceof Usuario u ? u : null;
  }

  /** Token da requisição, para o logout saber qual sessão revogar. */
  public static String tokenDaRequisicao(HttpServletRequest request) {
    Object token = request.getAttribute(ATRIBUTO_TOKEN);

    return token instanceof String t ? t : null;
  }

  /**
   * Usuário logado de uma rota marcada com {@link ExigeSessao}: aqui nunca é
   * nulo, porque o interceptor já barrou o resto.
   */
  public static Usuario usuarioObrigatorio(HttpServletRequest request) {
    Usuario usuario = usuarioDaRequisicao(request);

    if (usuario == null) {
      throw new IllegalStateException(
          "Rota autenticada sem usuário na requisição: faltou @ExigeSessao.");
    }

    return usuario;
  }
}
