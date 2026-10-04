package com.example.ecoportapi.Services;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.UsuarioToken;
import com.example.ecoportapi.Repositories.UsuarioTokenRepository;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Emissão e conferência do token de sessão.
 *
 * <p>O token é uma chave aleatória de 256 bits guardada no banco. Não é um
 * JWT: essa escolha compra revogação (o logout apaga a linha) e dispense
 * qualquer biblioteca de assinatura, ao preço de uma consulta por requisição
 * autenticada.
 */
@Service
public class TokenService {

  /** 30 dias: o app é usado de vez em quando, e dá para revogar se vazar. */
  private static final Duration VALIDADE = Duration.ofDays(30);

  private final UsuarioTokenRepository repositorio;
  private final SecureRandom aleatorio = new SecureRandom();

  public TokenService(UsuarioTokenRepository repositorio) {
    this.repositorio = repositorio;
  }

  /**
   * Cria a sessão e já varre as expiradas.
   *
   * <p>O {@code @Transactional} não é enfeite: {@code removerExpirados} é um
   * {@code @Modifying}, e query de escrita fora de transação estoura
   * {@code TransactionRequiredException} — o login virava 500 depois de a
   * senha já ter sido conferida.
   */
  @Transactional
  public String emitir(Usuario usuario) {
    UsuarioToken sessao = new UsuarioToken();
    sessao.setToken(gerarChave());
    sessao.setUsuario(usuario);
    sessao.setDataCriacao(LocalDateTime.now());
    sessao.setDataExpiracao(LocalDateTime.now().plus(VALIDADE));

    repositorio.save(sessao);

    // opportunista: toda vez que alguém entra, a bagunça antiga é varrida.
    repositorio.removerExpirados(LocalDateTime.now());

    return sessao.getToken();
  }

  /** Usuário dono de um token válido, ou vazio se não valer. */
  public Optional<Usuario> usuarioDoToken(String token) {
    if (token == null || token.isBlank()) {
      return Optional.empty();
    }

    UsuarioToken sessao = repositorio.buscarValido(token, LocalDateTime.now()).orElse(null);

    if (sessao == null) {
      return Optional.empty();
    }

    sessao.setUltimoUso(LocalDateTime.now());

    return Optional.of(sessao.getUsuario());
  }

  /** Revoga só esta sessão (o botão "Sair da conta"). */
  @Transactional
  public void revogar(String token) {
    if (token == null || token.isBlank()) return;

    repositorio
        .porToken(token)
        .ifPresent(repositorio::delete);
  }

  /** Revoga todas as sessões da conta ("sair de todos os lugares"). */
  @Transactional
  public int revogarTodas(Long usuarioId) {
    List<UsuarioToken> sessoes = repositorio.findDoUsuario(usuarioId);

    repositorio.deleteAll(sessoes);

    return sessoes.size();
  }

  /**
   * 32 bytes aleatórios em base64 url-safe.
   *
   * <p>Usa o {@link SecureRandom}, não o {@code Random} da JDK: este último
   * é previsível, e um token previsível é a mesma coisa que não ter token.
   */
  private String gerarChave() {
    byte[] bytes = new byte[32];
    aleatorio.nextBytes(bytes);

    return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
  }
}
