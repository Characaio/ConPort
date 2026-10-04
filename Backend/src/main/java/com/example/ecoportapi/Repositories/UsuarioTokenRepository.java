package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.UsuarioToken;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioTokenRepository extends JpaRepository<UsuarioToken, Long> {

  /**
   * Token válido de um usuário, com o usuário junto.
   *
   * <p>A validade é filtrada na própria query: assim um token expirado nem
   * chega a ser materializado, e a checagem de expiração fica em um lugar só.
   * O {@code JOIN FETCH} evita a segunda consulta para pegar o usuário.
   */
  @Query("""
          SELECT t FROM UsuarioToken t
          JOIN FETCH t.Usuario
          WHERE t.Token = :token
          AND t.DataExpiracao > :agora
      """)
  Optional<UsuarioToken> buscarValido(
      @Param("token") String token, @Param("agora") LocalDateTime agora);

  @Query("""
          SELECT t FROM UsuarioToken t
          WHERE t.Usuario.Id = :usuarioId
      """)
  List<UsuarioToken> findDoUsuario(@Param("usuarioId") Long usuarioId);

  /**
   * Token por valor, sem filtro de validade: o logout precisa achar a sessao
   * mesmo para revogar uma que ja expirou.
   *
   * <p>JPQL explicito, e não `findByToken`: com o Hibernate 7 o nome derivado
   * vira {@code u.token} e o atributo é {@code Token} — UnknownPathException.
   */
  @Query("""
          SELECT t FROM UsuarioToken t
          WHERE t.Token = :token
      """)
  Optional<UsuarioToken> porToken(@Param("token") String token);

  /** Sessão morta some sozinha: chamada depois de cada login. */
  @Modifying
  @Query("""
          DELETE FROM UsuarioToken t
          WHERE t.DataExpiracao < :agora
      """)
  int removerExpirados(@Param("agora") LocalDateTime agora);
}
