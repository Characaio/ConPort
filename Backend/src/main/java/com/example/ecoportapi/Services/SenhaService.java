package com.example.ecoportapi.Services;

import java.util.regex.Pattern;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Hash e conferência de senha.
 *
 * <p>A conta nasceu com a senha em texto puro na coluna {@code senha}. Ela
 * continua assim até a pessoa entrar uma vez: aí o login reconhece o formato
 * antigo, compara e **reescreve a coluna com o hash**. Quem não entrou desde
 * a mudança ainda tem a senha em texto puro no banco — até lá, o preço é a
 * comparação em Java, que só roda para quem já está no formato novo.
 */
@Service
public class SenhaService {

  /**
   * 12 rounds. Custa ~200ms por hash no login e no cadastro, e é o custo
   * mínimo que a OWASP considera aceitável hoje.
   */
  private static final int ROUNDS = 12;

  private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(ROUNDS);

  /**
   * Formato do BCrypt: {@code $2a$}, {@code $2b$} ou {@code $2y$}, seguido
   * de custo e sal.
   */
  private static final Pattern BCRYPT =
      Pattern.compile("^\\$2[aby]\\$\\d\\d\\$.{53}$");

  public String gerarHash(String senha) {
    return encoder.encode(senha);
  }

  /**
   * A senha confere com o que está gravado, venha ele do formato novo ou do
   * antigo.
   */
  public boolean conferir(String senhaDigitada, String senhaGuardada) {
    if (senhaDigitada == null || senhaGuardada == null || senhaGuardada.isBlank()) {
      return false;
    }

    if (estaHasheada(senhaGuardada)) {
      return encoder.matches(senhaDigitada, senhaGuardada);
    }

    // Formato antigo: comparação direta, só para a conta que ainda não
    // entrou desde a mudança.
    return senhaDigitada.equals(senhaGuardada);
  }

  /** A senha guardada já é um hash BCrypt? */
  public boolean estaHasheada(String senhaGuardada) {
    return senhaGuardada != null && BCRYPT.matcher(senhaGuardada).matches();
  }

  /** True quando o login deu certo e vale reescrever a coluna. */
  public boolean precisaMigrar(String senhaGuardada) {
    return senhaGuardada != null && !estaHasheada(senhaGuardada);
  }
}
