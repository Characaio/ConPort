package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Usuario;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

  // Com o Hibernate 7 (Spring Boot 4) o JPQL derivado exige o nome exato do
  // atributo, por isso a query e explicita em vez de findByEmailAndSenha.
  @Query("""
          SELECT u FROM Usuario u
          WHERE u.Email = :email AND u.Senha = :senha
      """)
  Optional<Usuario> buscarPorEmailESenha(
      @Param("email") String email, @Param("senha") String senha);

  @Query("""
          SELECT COUNT(u) > 0 FROM Usuario u
          WHERE u.Email = :email AND u.Senha = :senha
      """)
  boolean existePorEmailESenha(
      @Param("email") String email, @Param("senha") String senha);  // Na edicao de perfil o proprio usuario nao conta como conflito: ele pode
  // salvar o username/e-mail que ja tem sem tomar 409.
  @Query("""
          SELECT COUNT(u) > 0 FROM Usuario u
          WHERE UPPER(u.Username) = UPPER(:username) AND u.Id <> :usuarioId
      """)
  boolean existePorUsernameDeOutro(
      @Param("username") String username, @Param("usuarioId") Long usuarioId);

  @Query("""
          SELECT COUNT(u) > 0 FROM Usuario u
          WHERE LOWER(u.Email) = LOWER(:email) AND u.Id <> :usuarioId
      """)
  boolean existePorEmailDeOutro(
      @Param("email") String email, @Param("usuarioId") Long usuarioId);

  @Query("""
          SELECT COUNT(r)
          FROM Report r
          WHERE r.Usuario.Id = :usuarioId
      """)
  long countReportsEnviados(Long usuarioId);

  @Query(
      """
          SELECT COUNT(r)
          FROM Report r
          WHERE r.Usuario.Id = :usuarioId
          AND r.Status = :status
      """)
  long countReportsByStatus(Long usuarioId, StatusReport status);

  // ~ Cae
  @Query("""
          SELECT COUNT(u) > 0 FROM Usuario u
          WHERE UPPER(u.Username) = UPPER(:username)
      """)
  boolean existePorUsername(@Param("username") String username);  // Seguidores/Seguindo saem de UsuarioSegueRepository: contam follow, e
  // todo amigo é follow.

  @Query("""
          SELECT u FROM Usuario u
          WHERE u.Id <> :usuarioId
          AND (LOWER(u.Username) LIKE LOWER(CONCAT('%', :termo, '%'))
               OR LOWER(u.Nome) LIKE LOWER(CONCAT('%', :termo, '%')))
          ORDER BY
              CASE WHEN LOWER(u.Username) = LOWER(:termo) THEN 0 ELSE 1 END,
              u.Nome
      """)
  List<Usuario> buscar(
      @Param("usuarioId") Long usuarioId, @Param("termo") String termo, Pageable pageable);

  // Mesma busca sem excluir ninguem, para quando nao ha sessao.
  @Query(
      """
          SELECT u FROM Usuario u
          WHERE LOWER(u.Username) LIKE LOWER(CONCAT('%', :termo, '%'))
             OR LOWER(u.Nome) LIKE LOWER(CONCAT('%', :termo, '%'))
          ORDER BY
              CASE WHEN LOWER(u.Username) = LOWER(:termo) THEN 0 ELSE 1 END,
              u.Nome
      """)
  List<Usuario> buscarSemExcluir(@Param("termo") String termo, Pageable pageable);
}
