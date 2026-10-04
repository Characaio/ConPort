package com.example.ecoportapi.Services;

import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.TipoMissao;
import com.example.ecoportapi.Models.Missao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Catálogo fixo de missões entregue a todo usuário novo.
 *
 * São 3 missões, uma de cada tipo. Não é administrável ainda: nascem prontas,
 * todas em DISPONIVEL e com prazo de {@link #DIAS_PRAZO} dias.
 */
@Service
public class CatalogoMissoes {

  private static final int DIAS_PRAZO = 7;

  private final MissaoRepository missaoRepository;
  private final UsuarioRepository usuarioRepository;

  public CatalogoMissoes(
      MissaoRepository missaoRepository, UsuarioRepository usuarioRepository) {
    this.missaoRepository = missaoRepository;
    this.usuarioRepository = usuarioRepository;
  }

  /** Cria as missões de um usuário. Não faz nada se ele já tiver alguma. */
  @Transactional
  public List<Missao> criarPara(Usuario usuario) {
    if (missaoRepository.existeAlgumaDoUsuario(usuario.getId())) {
      return List.of();
    }

    return criarTodas(usuario);
  }

  /**
   * Cria as missoes para todos os usuarios que ainda nao tem nenhuma.
   *
   * Usado para quem foi cadastrado antes do catalogo existir. Ignora quem ja
   * tem missao: nao duplica nem sobrescreve progresso.
   */
  @Transactional
  public int criarParaUsuariosSemMissao() {
    int criadas = 0;

    for (Usuario usuario : usuarioRepository.findAll()) {
      if (!missaoRepository.existeAlgumaDoUsuario(usuario.getId())) {
        criarTodas(usuario);
        criadas++;
      }
    }

    return criadas;
  }

  private List<Missao> criarTodas(Usuario usuario) {
    LocalDateTime inicio = LocalDateTime.now();
    LocalDateTime fechamento = inicio.plusDays(DIAS_PRAZO);

    List<Missao> missoes = new ArrayList<>(List.of(
        nova(usuario, "Separar para Reciclar",
            "Separe corretamente materiais recicláveis dos resíduos comuns "
                + "e encaminhe-os para a coleta adequada.",
            TipoMissao.RECICLAR, 5, 50, 30, inicio, fechamento),
        nova(usuario, "Plante uma Nova Vida",
            "Plante uma muda ou cuide de uma planta, contribuíndo para "
                + "o aumento da vegetação.",
            TipoMissao.PLANTAR, 1, 60, 40, inicio, fechamento),
        nova(usuario, "Dê uma Nova Utilidade",
            "Reutilize um objeto que seria descartado, encontrando "
                + "uma nova função para ele.",
            TipoMissao.REUTILIZAR, 2, 50, 30, inicio, fechamento)));

    return missaoRepository.saveAll(missoes);
  }

  private Missao nova(
      Usuario usuario,
      String titulo,
      String descricao,
      TipoMissao tipo,
      int meta,
      int xpRecompensa,
      int moedaRecompensa,
      LocalDateTime inicio,
      LocalDateTime fechamento) {

    Missao missao = new Missao();
    missao.setUsuario(usuario);
    missao.setTitulo(titulo);
    missao.setDescricao(descricao);
    missao.setTipoDeMissao(tipo);
    missao.setStatusMissao(StatusMissao.DISPONIVEL);
    missao.setMeta(meta);
    missao.setProgresso(0);
    missao.setXpRecompensa(xpRecompensa);
    missao.setMoedaRecompensa(moedaRecompensa);
    missao.setTempoDeInicio(inicio);
    missao.setTempoFechamento(fechamento);
    return missao;
  }
}