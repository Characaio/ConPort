package com.example.ecoportapi;

import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.*;
import com.example.ecoportapi.Models.Enums.*;
import com.example.ecoportapi.Repositories.*;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class CriadorDeValoresMock implements CommandLineRunner {

  // Imagens do seed: a tela usa a URL direto, e sem foto cadastrada o card
  // cai no placeholder.
  private static final String IMAGEM_UNIDADE =
      "https://upload.wikimedia.org/wikipedia/commons/7/71/Capybaracropped.jpg";
  private static final String IMAGEM_MATA =
      "https://upload.wikimedia.org/wikipedia/commons/b/b9/The_tree_in_forest.jpg";
  private static final String IMAGEM_CAPIVARA =
      "https://upload.wikimedia.org/wikipedia/commons/f/fb/Lone_capybara.jpg";

  private final UnidadeRepository unidadeRepository;
  private final ReportRepository reportRepository;
  private final UsuarioRepository usuarioRepository;
  private final SupervisorRepository supervisorRepository;
  private final AvisoRepository avisoRepository;
  private final EspecieRepository especieRepository;
  private final com.example.ecoportapi.Services.CatalogoMissoes catalogoMissoes;

  public CriadorDeValoresMock(
      UnidadeRepository unidadeRepository,
      ReportRepository reportRepository,
      UsuarioRepository usuarioRepository,
      SupervisorRepository supervisorRepository,
      AvisoRepository avisoRepository,
      EspecieRepository especieRepository,
      com.example.ecoportapi.Services.CatalogoMissoes catalogoMissoes) {
    this.unidadeRepository = unidadeRepository;
    this.reportRepository = reportRepository;
    this.usuarioRepository = usuarioRepository;
    this.supervisorRepository = supervisorRepository;
    this.avisoRepository = avisoRepository;
    this.especieRepository = especieRepository;
    this.catalogoMissoes = catalogoMissoes;
  }

  private void CriarUnidade() {

    if (unidadeRepository.count() > 0) {
      return;
    }
    UnidadeDeConservacao unidade = new UnidadeDeConservacao();

    unidade.setNome("Parque Estadual da Serra Verde");

    unidade.setLatitude(10D);
    unidade.setLongitude(8D);

    unidade.setDescricao("Gourmet");

    unidade.setImagem(IMAGEM_UNIDADE);

    unidade.setTipoDeUnidade(TipoDeUnidade.PARQUE_NACIONAL);
    unidade.setBioma("Mata Atlântica");

    unidade.setAreaTotal(4820.50);
    unidade.setAreaRegularizada(4380.20);
    unidade.setAreaPreservada(4215.80);
    unidade.setAreaMonitorada(3890.00);

    unidade.setPontosMonitorados(42);
    unidade.setPontosPrevistos(50);

    unidade.setAreaBasePorCorredor(500.0);
    unidade.setQuantidadeCorredores(8);

    unidade.setQuantidadeEspecies(327);
    unidade.setQuantidadeEspeciesEsperadas(360);

    unidade.setQualidadeAgua(86.5);
    unidade.setQualidadeSolo(91.2);
    unidade.setGestaoResiduos(78.0);

    unidade.setTelefone("1934567821");
    unidade.setHoraAbertura(LocalTime.of(8, 0));
    unidade.setHoraFechamento(LocalTime.of(17, 0));

    unidadeRepository.save(unidade);
  }

  private void CriarUsuariosBase() {
    if (usuarioRepository.count() > 0) {
      return;
    }

    Usuario usuario1 = new Usuario();
    usuario1.setNome("Carlos Silva");
    usuario1.setUsername("carlos");
    usuario1.setDataNasc(LocalDate.of(2001, 5, 14));
    usuario1.setEmail("carlos.silva@gmail.com");
    usuario1.setSenha("123456");
    usuario1.setConfiavel(true);
    usuario1.setCidade("Santa Bárbara d'Oeste");
    usuario1.setEstado("São Paulo");
    usuario1.setXP(150);
    usuario1.setLevel(2);
    usuario1.setMoedas(80);
    usuario1.setReputacao(10D);

    Usuario usuario2 = new Usuario();
    usuario2.setNome("Ana Oliveira");
    usuario2.setUsername("ana");
    usuario2.setDataNasc(LocalDate.of(2003, 8, 22));
    usuario2.setEmail("ana.oliveira@gmail.com");
    usuario2.setSenha("123456");
    usuario2.setConfiavel(true);
    usuario2.setCidade("Santa Bárbara d'Oeste");
    usuario2.setEstado("São Paulo");
    usuario2.setXP(320);
    usuario2.setLevel(4);
    usuario2.setMoedas(150);
    usuario2.setReputacao(25D);

    Usuario usuario3 = new Usuario();
    usuario3.setNome("Lucas Santos");
    usuario3.setUsername("lucas");
    usuario3.setDataNasc(LocalDate.of(2000, 11, 3));
    usuario3.setEmail("lucas.santos@gmail.com");
    usuario3.setSenha("123456");
    usuario3.setConfiavel(false);
    usuario3.setCidade("Campinas");
    usuario3.setEstado("São Paulo");
    usuario3.setXP(70);
    usuario3.setLevel(1);
    usuario3.setMoedas(40);
    usuario3.setReputacao(5D);

    usuarioRepository.saveAll(List.of(usuario1, usuario2, usuario3));
  }

  private void CriarSupervisor() {
    if (supervisorRepository.count() > 0) {
      return;
    }
    SupervisorDeUnidade supervisorDeUnidade = new SupervisorDeUnidade();

    supervisorDeUnidade.setUnidade(
        unidadeRepository
            .findById(1L)
            .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade Não Encontrada")));
    supervisorDeUnidade.setUsuario(
        usuarioRepository
            .findById(1L)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario Não Encontrada")));

    supervisorRepository.save(supervisorDeUnidade);
  }

  private void CriarReport() {
    if (reportRepository.count() > 0) {
      return;
    }
    Report report1 = new Report();
    Report report2 = new Report();
    SupervisorDeUnidade supervisorDeUnidade =
        supervisorRepository
            .findById(1L)
            .orElseThrow(() -> new SupervisorNaoEncontrado("Supervisor Não Encontrado"));
    UnidadeDeConservacao unidadeDeConservacao =
        unidadeRepository
            .findById(1L)
            .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade Não Encontrada"));
    Usuario usuario =
        usuarioRepository
            .findById(2L)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario Não Encontrado"));
    report1.setUnidade(unidadeDeConservacao);
    report2.setUnidade(unidadeDeConservacao);

    report1.setUsuario(usuario);
    report2.setUsuario(usuario);

    report1.setTipo(TipoDeIncidente.QUEIMADA);
    report2.setTipo(TipoDeIncidente.ANIMAL_EXOTICO);

    report1.setSupervisor(supervisorDeUnidade);
    report2.setSupervisor(supervisorDeUnidade);

    report1.setDescricao("Queimada de pequena escala detectada");
    report2.setDescricao("Familia de Javali avistado rondando as trilhas principais");

    report1.setDataDoOcorrido(LocalDateTime.of(2026, 3, 24, 14, 35, 49));
    report2.setDataDoOcorrido(LocalDateTime.of(2026, 3, 25, 16, 15, 20));

    report1.setDataDaAnalisa(LocalDateTime.of(2026, 3, 24, 16, 25, 6));
    report2.setDataDaAnalisa(LocalDateTime.of(2026, 3, 30, 10, 26, 24));

    report1.setStatus(StatusReport.NEGADO);
    report1.setMotivoDaNegacao("Report falso sobre a ocorrencia, a queimada era falsa");

    report2.setStatus(StatusReport.TRATADO);

    report1.setPrioridade(ReportPrioridade.ALARMANTE);
    report2.setPrioridade(ReportPrioridade.MEDIA);

    report1.setLongitude(0D);
    report2.setLongitude(0D);

    report1.setLatitude(0D);
    report2.setLatitude(0D);

    report1.setLocalizacaoOrigem(LocalizacaoOrigem.MAPA_MANUAL);
    report2.setLocalizacaoOrigem(LocalizacaoOrigem.MAPA_MANUAL);

    reportRepository.saveAll(List.of(report1, report2));
  }

  private Missao criar(
      Usuario usuario,
      String titulo,
      String descricao,
      TipoMissao tipo,
      int meta,
      int recompensaXP,
      int recompensaMoedas,
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

    missao.setXpRecompensa(recompensaXP);
    missao.setMoedaRecompensa(recompensaMoedas);

    missao.setTempoDeInicio(inicio);
    missao.setTempoFechamento(fechamento);

    return missao;
  }

  /** As missoes vem do mesmo catalogo entregue no cadastro. */
  public void CriarMissoes() {
    Usuario usuario =
        usuarioRepository
            .findById(2L)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

    catalogoMissoes.criarPara(usuario);
  }

  private UnidadeDeConservacao primeiraUnidade() {
    return unidadeRepository
        .findById(1L)
        .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade Não Encontrada"));
  }

  /**
   * Unidade que ja existia antes da coluna Imagem: sem isso ela ficaria sem
   * foto para sempre, porque CriarUnidade so roda em banco vazio.
   */
  private void GarantirImagemDaUnidade() {
    UnidadeDeConservacao unidade = primeiraUnidade();

    if (unidade.getImagem() != null && !unidade.getImagem().isBlank()) {
      return;
    }

    unidade.setImagem(IMAGEM_UNIDADE);
    unidadeRepository.save(unidade);
  }

  private Aviso aviso(String titulo, String conteudo, LocalDateTime horario, Boolean fixo, String imagem) {
    Aviso aviso = new Aviso();
    aviso.setUnidade(primeiraUnidade());
    aviso.setTitulo(titulo);
    aviso.setConteudo(conteudo);
    aviso.setHorarioDoAviso(horario);
    aviso.setFixo(fixo);
    aviso.setImagem(imagem);
    return aviso;
  }

  /**
   * Anuncios da unidade.
   *
   * Antes nao havia nenhum aviso no banco, entao a tela de anuncios e a
   * faixa do mapa vinham vazias.
   */
  private void CriarAvisos() {
    if (avisoRepository.count() > 0) {
      return;
    }

    LocalDateTime agora = LocalDateTime.now();

    avisoRepository.saveAll(List.of(
        aviso(
            "Trilhas reabertas",
            "As trilhas da mata voltaram a receber visitantes depois da "
                + "limpeza da semana passada. Continue excessive a sinalizacao.",
            agora.minusDays(2),
            true,
            IMAGEM_MATA),
        aviso(
            "Monitoramento da qualidade da agua",
            "A campanha de coleta de agua do mes comeca na proxima segunda. "
                + "Os pontos de monitoramento seront sinalizados na trilha principal.",
            agora.minusDays(6),
            false,
            null),
        aviso(
            "Campanha de-fauna",
            "Encontro de identificacao de fauna com especialistas. As inscricoes "
                + "ficam abertas ate o fim do mes.",
            agora.minusDays(12),
            false,
            null),
        aviso(
            "Areas de descanso",
            "As areas de descanso continuam fechadas para visitacao para "
                + "proteger a nidificacao. Use as dependencias tracejadas.",
            agora.minusDays(21),
            false,
            null)
    ));
  }

  private Especie especie(String nome, String cientifico, String descricao, String imagem, TipoEspecie tipo) {
    Especie especie = new Especie();
    especie.setUnidade(primeiraUnidade());
    especie.setNome(nome);
    especie.setNomeCientifico(cientifico);
    especie.setDescricao(descricao);
    especie.setImagem(imagem);
    especie.setTipo(tipo);
    return especie;
  }

  /** Especies da unidade, para a tela de ecossistema. */
  private void CriarEspecies() {
    if (especieRepository.contarDaUnidade(1L) > 0) {
      return;
    }

    especieRepository.saveAll(List.of(
        especie(
            "Capivara",
            "Hydrochoerus hydrochaeris",
            "Maior roedor do mundo, de habitos semiaquaticos. Vive em grupos "
                + "perto de rios, lagos e areas alagadas da unidade.",
            IMAGEM_CAPIVARA,
            TipoEspecie.FAUNA),
        especie(
            "Lobo-guara",
            "Chrysocyon brachyurus",
            "Carnivoro endemico da América do Sul, procura alimento mainly "
                + "em areas abertas de grama e mato.",
            null,
            TipoEspecie.FAUNA),
        especie(
            "Jaguatirica",
            "Leopardus pardalis",
            "Felino de porte pequeno e noturno, registrado na faixa de "
                + "vegetacao mais densa da mata.",
            null,
            TipoEspecie.FAUNA),
        especie(
            "Araucaria",
            "Araucaria angustifolia",
            "Arvore simbolo da Mata Atlantica, com copas altas que marcam o "
                + "dossel da floresta da unidade.",
            IMAGEM_MATA,
            TipoEspecie.FLORA),
        especie(
            "Ipe-amarelo",
            "Handroanthus albus",
            "Arvore nativa que floresce no fim do inverno e e uma das "
                + "especies mais frecuentes na unidade.",
            null,
            TipoEspecie.FLORA),
        especie(
            "Palmeira-leque",
            "Syagrus romanzoffiana",
            "Palmeira comum nas areas de borda da mata, com frutos "
                + "aproveitados pela fauna nativa.",
            null,
            TipoEspecie.FLORA),
        especie(
            "Samambaia",
            "Pteridophyta",
            "Vegetação que se destaca nas areas umidas e nas margens dos "
                + "cursos d'agua da unidade.",
            null,
            TipoEspecie.FLORA)
    ));
  }

  @Override
  public void run(String... args) {
    CriarUnidade();
    CriarUsuariosBase();
    CriarSupervisor();
    CriarReport();
    CriarMissoes();
    CriarAvisos();
    CriarEspecies();
    GarantirImagemDaUnidade();

    // Contas criadas antes do catalogo existir ficam sem missao.
    int preenchidas = catalogoMissoes.criarParaUsuariosSemMissao();

    if (preenchidas > 0) {
      System.out.println("[mock] missoes criadas para " + preenchidas + " conta(s)");
    }
  }
}
