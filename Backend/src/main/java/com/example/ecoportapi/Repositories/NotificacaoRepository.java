package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Notificacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NotificacaoRepository extends JpaRepository<Notificacao, Long> {

    // Com o Hibernate 7 o nome derivado precisa bater com o atributo, por isso
    // as queries são explícitas (mesma razão do ConquistaDesbloqueadaRepository).

    /**
     * Todas do usuário, da mais recente para a mais antiga.
     *
     * A data desempata: duas notificações podem ter o mesmo timestamp e o app
     * precisa de uma ordem estável para a lista não "pular" ao recarregar.
     */
    @Query("""
        SELECT n
        FROM Notificacao n
        WHERE n.Usuario.Id = :usuarioId
        ORDER BY n.Data DESC, n.Id DESC
    """)
    List<Notificacao> listarDoUsuario(@Param("usuarioId") Long usuarioId);

    /** Só as não lidas, para o sino/badge do topo da tela. */
    @Query("""
        SELECT n
        FROM Notificacao n
        WHERE n.Usuario.Id = :usuarioId
          AND n.Lida = false
        ORDER BY n.Data DESC, n.Id DESC
    """)
    List<Notificacao> listarNaoLidasDoUsuario(@Param("usuarioId") Long usuarioId);

    /**
     * Busca a notificação já exigindo que seja do usuário da URL.
     *
     * Sem essa checagem no WHERE, daria para ler/marcar a notificação de outra
     * pessoa só de trocar o id.
     */
    @Query("""
        SELECT n
        FROM Notificacao n
        WHERE n.Id = :notificacaoId
          AND n.Usuario.Id = :usuarioId
    """)
    Optional<Notificacao> buscarDoUsuario(
            @Param("usuarioId") Long usuarioId,
            @Param("notificacaoId") Long notificacaoId
    );

    @Query("""
        SELECT COUNT(n)
        FROM Notificacao n
        WHERE n.Usuario.Id = :usuarioId
          AND n.Lida = false
    """)
    Long contarNaoLidasDoUsuario(@Param("usuarioId") Long usuarioId);

    /**
     * Marca todas as não lidas do usuário como lidas.
     *
     * UPDATE direto no banco: sem isso o app teria de ler e salvar item por
     * item. Devolve quantas linhas mudaram, o que o service usa na resposta.
     */
    @Modifying
    @Query("""
        UPDATE Notificacao n
        SET n.Lida = true
        WHERE n.Usuario.Id = :usuarioId
          AND n.Lida = false
    """)
    int marcarTodasComoLidas(@Param("usuarioId") Long usuarioId);
}
