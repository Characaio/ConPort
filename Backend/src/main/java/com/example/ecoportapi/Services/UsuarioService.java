package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.AtualizarPerfilDTO;
import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.DTOs.Request.VisibilidadeDTO;
import com.example.ecoportapi.DTOs.Request.LoginDTO;
import com.example.ecoportapi.DTOs.Request.SignupDTO;
import com.example.ecoportapi.DTOs.Response.AvatarResponseDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioResumoDTO;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.Enums.VisibilidadeSeguidores;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.UsuarioRelacionamento;
import com.example.ecoportapi.Models.UsuarioSegue;
import com.example.ecoportapi.Repositories.RelacionamentoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import com.example.ecoportapi.Repositories.UsuarioSegueRepository;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UsuarioService {

  private final UsuarioRepository usuarioRepository;
  private final RelacionamentoRepository relacionamentoRepository;
  private final UsuarioSegueRepository usuarioSegueRepository;
  private final ImagemService imagemService;
  private final CatalogoMissoes catalogoMissoes;
  private final NotificacaoService notificacaoService;

  public UsuarioService(
      UsuarioRepository usuarioRepository,
      RelacionamentoRepository relacionamentoRepository,
      UsuarioSegueRepository usuarioSegueRepository,
      ImagemService imagemService,
      CatalogoMissoes catalogoMissoes,
      NotificacaoService notificacaoService) {
    this.usuarioRepository = usuarioRepository;
    this.relacionamentoRepository = relacionamentoRepository;
    this.usuarioSegueRepository = usuarioSegueRepository;
    this.imagemService = imagemService;
    this.catalogoMissoes = catalogoMissoes;
    this.notificacaoService = notificacaoService;
  }

  public void CalcularReputação() {}

  public ResponseEntity<?> Signup(SignupDTO signupDTO) {
    Usuario usuario = new Usuario();

    if (usuarioRepository.existePorEmailESenha(signupDTO.email(), signupDTO.senha())) {
      return ResponseEntity.status(HttpStatus.CONFLICT).body("Usuario Ja existe");
    }

    usuario.setNome(signupDTO.nome());
    usuario.setDataNasc(signupDTO.dataNasc());
    usuario.setEmail(signupDTO.email());
    usuario.setSenha(signupDTO.senha());
    usuario.setEstado(signupDTO.estado());
    usuario.setCidade(signupDTO.cidade());
    usuario.setConfiavel(false);
    usuario.setXP(0);
    usuario.setLevel(0);
    usuario.setMoedas(0);
    usuario.setReputacao(0D);
    String username = signupDTO.username() == null ? null : signupDTO.username().trim().toLowerCase();

    if (username == null || !username.matches("^[a-z0-9_.]{3,24}$")) {
      return ResponseEntity.badRequest()
          .body(
              "Username deve ter de 3 a 24 caracteres, "
                  + "apenas letras minúsculas, números, ponto ou _");
    }

    if (usuarioRepository.existePorUsername(username)) {
      return ResponseEntity.status(HttpStatus.CONFLICT).body("Username já em uso");
    }

    usuario.setUsername(username);
    usuario.setAvatar(null);
    Usuario salvo = usuarioRepository.save(usuario);

    // Todo usuario novo comeca com o catalogo de missoes.
    catalogoMissoes.criarPara(salvo);

    // Boas-vindas: o app mostra no sino assim que entra, e ela precisa
    // existir mesmo que a pessoa feche o app no meio do cadastro.
    notificacaoService.avisar(
        salvo,
        "Bem-vindo ao ConPort!",
        "Sua conta foi criada. Agora você pode enviar reports, acompanhar "
            + "missões e encontrar outras pessoas ajudando a cuidar do "
            + "meio ambiente."
    );

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  public ResponseEntity<?> Login(LoginDTO loginDTO) {
    Usuario usuario =
        usuarioRepository
            .buscarPorEmailESenha(loginDTO.email(), loginDTO.senha())
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));
    // Sem sessão ainda não existe "quem está vendo": o app abre a própria tela
    // logo depois e o perfil neutro serve.
    return ResponseEntity.ok(montarDto(usuario, null));
  }

  // ~ Cae
  public UsuarioDTO pegarUsuario(Long usuarioId, Long visorId) {
    Usuario usuario = buscarUsuario(usuarioId);

    return montarDto(usuario, visorId);
  }

  /**
   * Perfil com o estado do relacionamento em relação a quem está vendo.
   *
   * <p>Seguidores e Seguindo agora contam follows, não amizades: como todo
   * amigo vira seguidor mútuo ao aceitar a amizade, o número nunca fica
   * menor que a lista de amigos.
   */
  private UsuarioDTO montarDto(Usuario usuario, Long visorId) {
    long seguidores = usuarioSegueRepository.countSeguidores(usuario.getId());
    long seguindo = usuarioSegueRepository.countSeguindo(usuario.getId());

    boolean euMesmo = visorId != null && visorId.equals(usuario.getId());

    boolean amigo =
        !euMesmo
            && visorId != null
            && relacionamentoRepository.existeAmizade(
                visorId, usuario.getId(), StatusRelacionamento.ACEITO);

    boolean euSigo =
        !euMesmo
            && visorId != null
            && usuarioSegueRepository.existe(visorId, usuario.getId());

    boolean segueMe =
        !euMesmo
            && visorId != null
            && usuarioSegueRepository.existe(usuario.getId(), visorId);

    return new UsuarioDTO(usuario, seguidores, seguindo, amigo, euSigo, segueMe);
  }

  public List<UsuarioResumoDTO> listarAmigos(Long usuarioId) {
    return relacionamentoRepository.findComStatus(usuarioId, StatusRelacionamento.ACEITO).stream()
        .map(r -> new UsuarioResumoDTO(r.getSeguindo(), r.getId()))
        .toList();
  }

  public List<UsuarioResumoDTO> listarSolicitacoes(Long usuarioId) {
    return relacionamentoRepository
        .findComStatusRecebidas(usuarioId, StatusRelacionamento.PENDENTE)
        .stream()
        .map(r -> new UsuarioResumoDTO(r.getSeguidor(), r.getId()))
        .toList();
  }

  public List<UsuarioResumoDTO> buscar(Long usuarioId, String termo) {
    String limpo = termo == null ? "" : termo.trim();

    if (limpo.length() < 2) {
      return List.of();
    }

    // Sem sessao, a busca nao exclui ninguem (usuarioId nulo).
    List<Usuario> encontrados =
        usuarioId == null
            ? usuarioRepository.buscarSemExcluir(limpo, PageRequest.of(0, 20))
            : usuarioRepository.buscar(usuarioId, limpo, PageRequest.of(0, 20));

    return encontrados.stream().map(UsuarioResumoDTO::new).toList();
  }

  public ResponseEntity<?> enviarSolicitacao(Long usuarioId, Long alvoId) {
    if (usuarioId.equals(alvoId)) {
      return ResponseEntity.badRequest().body("Você não pode enviar solicitação para si mesmo");
    }

    usuarioRepository
        .findById(alvoId)
        .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

    var existente = relacionamentoRepository.buscar(usuarioId, alvoId);

    if (existente.isPresent()) {
      return ResponseEntity.status(HttpStatus.CONFLICT)
          .body("Já existe uma solicitação ou amizade");
    }

    Usuario eu =
        usuarioRepository
            .findById(usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));
    Usuario alvo =
        usuarioRepository
            .findById(alvoId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

    UsuarioRelacionamento nova = new UsuarioRelacionamento();
    nova.setSeguidor(eu);
    nova.setSeguindo(alvo);
    relacionamentoRepository.save(nova);

    // Aviso de quem recebeu, e não de quem pediu: a solicitação fica na caixa
    // de quem tem algo para responder.
    notificacaoService.avisar(
        alvo,
        "Nova solicitação de amizade",
        eu.getNome() + " quer ser seu amigo no ConPort. Abra o app para aceitar "
            + "ou recusar."
    );

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  public ResponseEntity<?> aceitar(Long usuarioId, Long relacaoId) {
    UsuarioRelacionamento relacao =
        relacionamentoRepository
            .buscarRecebida(relacaoId, usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Solicitação não encontrada"));

    relacao.setStatus(StatusRelacionamento.ACEITO);
    relacionamentoRepository.save(relacao);

    boolean espelhoExiste =
        relacionamentoRepository
            .buscar(
                relacao.getSeguindo().getId(), relacao.getSeguidor().getId())
            .isPresent();

    if (!espelhoExiste) {
      UsuarioRelacionamento espelho = new UsuarioRelacionamento();
      espelho.setSeguidor(relacao.getSeguindo());
      espelho.setSeguindo(relacao.getSeguidor());
      espelho.setStatus(StatusRelacionamento.ACEITO);
      relacionamentoRepository.save(espelho);
    }

    // Amigo vira seguidor mútuo: é o que garante que quem é amigo já
    // aparece nas listas sem ninguém precisar apertar "Seguir".
    seguirSilenciosamente(relacao.getSeguidor(), relacao.getSeguindo());
    seguirSilenciosamente(relacao.getSeguindo(), relacao.getSeguidor());

    // Os dois lados viram amigos, então os dois merecem o aviso — inclusive
    // quem pediu e está com o app fechado.
    Usuario quemPediu = relacao.getSeguidor();
    Usuario quemAceitou = relacao.getSeguindo();

    notificacaoService.avisar(
        quemAceitou,
        "Vocês agora são amigos!",
        "Você e " + quemPediu.getNome() + " são amigos no ConPort. "
            + "Agora vocês podem ver os reports um do outro."
    );

    notificacaoService.avisar(
        quemPediu,
        "Sua solicitação foi aceita!",
        quemAceitou.getNome() + " aceitou sua solicitação de amizade. "
            + "Vocês agora são amigos no ConPort."
    );

    return ResponseEntity.ok().build();
  }

  public ResponseEntity<?> recusar(Long usuarioId, Long relacaoId) {
    UsuarioRelacionamento relacao =
        relacionamentoRepository
            .buscarRecebida(relacaoId, usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Solicitação não encontrada"));

    if (relacao.getStatus() == StatusRelacionamento.ACEITO) {
      return ResponseEntity.badRequest().body("Isso é uma amizade, não uma solicitação");
    }

    relacionamentoRepository.delete(relacao);
    return ResponseEntity.ok().build();
  }

  public ResponseEntity<?> removerAmizade(Long usuarioId, Long alvoId) {
    var minha = relacionamentoRepository.buscar(usuarioId, alvoId);
    var dele = relacionamentoRepository.buscar(alvoId, usuarioId);

    minha.ifPresent(relacionamentoRepository::delete);
    dele.ifPresent(relacionamentoRepository::delete);

    // O follow criado junto da amizade fica: quem explicitamente seguiu a
    // pessoa continua vendo o que ela posta, mesmo depois de desfazer a
    // amizade.
    return ResponseEntity.noContent().build();
  }

  public ResponseEntity<?> atualizarAvatar(Long usuarioId, MultipartFile arquivo)
      throws IOException {
    Usuario usuario = buscarUsuario(usuarioId);

    ImagemProcessada imagem = imagemService.SalvarImagem(arquivo);

    String anterior = usuario.getAvatar();
    usuario.setAvatar(imagem.NomeArquivo());
    usuarioRepository.save(usuario);

    // O arquivo trocado nao serve mais para ninguem: sem isso cada troca de
    // foto deixava o upload-dir acumulando jpeg orfao.
    imagemService.RemoverImagem(anterior);

    return ResponseEntity.ok(new AvatarResponseDTO(imagem.NomeArquivo()));
  }

  public ResponseEntity<?> removerAvatar(Long usuarioId) {
    Usuario usuario = buscarUsuario(usuarioId);

    String anterior = usuario.getAvatar();
    usuario.setAvatar(null);
    usuarioRepository.save(usuario);

    imagemService.RemoverImagem(anterior);

    return ResponseEntity.noContent().build();
  }

  public ResponseEntity<?> atualizarPerfil(Long usuarioId, AtualizarPerfilDTO dto) {
    Usuario usuario = buscarUsuario(usuarioId);

    if (dto.nome() != null) {
      String nome = dto.nome().trim();

      if (nome.length() < 2 || nome.length() > 80) {
        return ResponseEntity.badRequest().body("Nome deve ter de 2 a 80 caracteres");
      }

      usuario.setNome(nome);
    }

    if (dto.username() != null) {
      String username = dto.username().trim().toLowerCase();

      if (!username.matches("^[a-z0-9_.]{3,24}$")) {
        return ResponseEntity.badRequest()
            .body(
                "Username deve ter de 3 a 24 caracteres, "
                    + "apenas letras minúsculas, números, ponto ou _");
      }

      if (usuarioRepository.existePorUsernameDeOutro(username, usuarioId)) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body("Username já em uso");
      }

      usuario.setUsername(username);
    }

    if (dto.email() != null) {
      String email = dto.email().trim().toLowerCase();

      if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
        return ResponseEntity.badRequest().body("E-mail inválido");
      }

      if (usuarioRepository.existePorEmailDeOutro(email, usuarioId)) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body("E-mail já em uso");
      }

      usuario.setEmail(email);
    }

    if (dto.dataNasc() != null) {
      LocalDate hoje = LocalDate.now();
      LocalDate maisAntigo = hoje.minusYears(120);

      if (dto.dataNasc().isAfter(hoje)) {
        return ResponseEntity.badRequest().body("Data de nascimento não pode ser futura");
      }

      if (dto.dataNasc().isBefore(maisAntigo)) {
        return ResponseEntity.badRequest().body("Data de nascimento inválida");
      }

      usuario.setDataNasc(dto.dataNasc());
    }

    if (dto.cidade() != null) {
      String cidade = dto.cidade().trim();

      if (cidade.length() < 2 || cidade.length() > 80) {
        return ResponseEntity.badRequest().body("Cidade deve ter de 2 a 80 caracteres");
      }

      usuario.setCidade(cidade);
    }

    if (dto.estado() != null) {
      String estado = dto.estado().trim();

      if (estado.length() < 2 || estado.length() > 80) {
        return ResponseEntity.badRequest().body("Estado deve ter de 2 a 80 caracteres");
      }

      usuario.setEstado(estado);
    }

    if (dto.senha() != null && !dto.senha().isBlank()) {
      String nova = dto.senha();

      if (nova.length() < 6) {
        return ResponseEntity.badRequest().body("A senha deve ter ao menos 6 caracteres");
      }

      // As rotas ainda nao tem autenticacao: sem conferir a senha atual,
      // qualquer um trocaria a senha de qualquer conta so pelo id da URL.
      String atual = dto.senhaAtual() == null ? "" : dto.senhaAtual();

      if (!usuario.getSenha().equals(atual)) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body("Senha atual incorreta");
      }

      usuario.setSenha(nova);
    }

    Usuario salvo = usuarioRepository.save(usuario);

    return ResponseEntity.ok(montarDto(salvo, null));
  }

  // ============================================================
  // SEGUIR / SEGUIDORES
  // ============================================================

  /**
   * Seguir é imediato e não pede nada: diferente da amizade, o outro lado não
   * precisa saber.
   */
  public ResponseEntity<?> seguir(Long usuarioId, Long alvoId) {
    if (usuarioId.equals(alvoId)) {
      return ResponseEntity.badRequest().body("Você não pode seguir a si mesmo");
    }

    Usuario eu = buscarUsuario(usuarioId);
    Usuario alvo = buscarUsuario(alvoId);

    if (usuarioSegueRepository.existe(usuarioId, alvoId)) {
      // Seguir duas vezes não é erro: o app pode tocar no botão sem saber o
      // estado salvo.
      return ResponseEntity.ok().build();
    }

    UsuarioSegue follow = new UsuarioSegue();
    follow.setSeguidor(eu);
    follow.setSeguindo(alvo);
    usuarioSegueRepository.save(follow);

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  public ResponseEntity<?> deixarDeSeguir(Long usuarioId, Long alvoId) {
    usuarioSegueRepository
        .buscar(usuarioId, alvoId)
        .ifPresent(usuarioSegueRepository::delete);

    return ResponseEntity.noContent().build();
  }

  public ResponseEntity<?> listarSeguindo(Long usuarioId, Long visorId) {
    Usuario usuario = buscarUsuario(usuarioId);

    if (!podeVerLista(usuario, visorId)) {
      return ResponseEntity.status(HttpStatus.FORBIDDEN)
          .body(mensagemListaPrivada(usuario));
    }

    return ResponseEntity.ok(
        usuarioSegueRepository.findQuemEuSigo(usuarioId).stream()
            .map(r -> new UsuarioResumoDTO(r.getSeguindo()))
            .toList());
  }

  public ResponseEntity<?> listarSeguidores(Long usuarioId, Long visorId) {
    Usuario usuario = buscarUsuario(usuarioId);

    if (!podeVerLista(usuario, visorId)) {
      return ResponseEntity.status(HttpStatus.FORBIDDEN)
          .body(mensagemListaPrivada(usuario));
    }

    return ResponseEntity.ok(
        usuarioSegueRepository.findQuemMeSegue(usuarioId).stream()
            .map(r -> new UsuarioResumoDTO(r.getSeguidor()))
            .toList());
  }

  /** Ajusta quem pode abrir as listas. Vale só para a própria conta. */
  public ResponseEntity<?> atualizarVisibilidade(Long usuarioId, VisibilidadeDTO dto) {
    if (dto == null || dto.visibilidade() == null) {
      return ResponseEntity.badRequest().body("Informe a visibilidade");
    }

    Usuario usuario = buscarUsuario(usuarioId);
    usuario.setVisibilidade(dto.visibilidade());
    usuarioRepository.save(usuario);

    return ResponseEntity.ok(
        new UsuarioDTO(
            usuario,
            usuarioSegueRepository.countSeguidores(usuarioId),
            usuarioSegueRepository.countSeguindo(usuarioId),
            false,
            false,
            false));
  }

  /**
   * Regras das listas, na ordem: o próprio sempre vê, depois o que o nível
   * escolhido permite.
   */
  private boolean podeVerLista(Usuario dono, Long visorId) {
    VisibilidadeSeguidores visibilidade = dono.getVisibilidade();

    if (visibilidade == null) return true;
    if (visorId != null && visorId.equals(dono.getId())) return true;
    if (visibilidade == VisibilidadeSeguidores.PUBLICO) return true;
    if (visibilidade == VisibilidadeSeguidores.PRIVADO) return false;

    return visorId != null
        && relacionamentoRepository.existeAmizade(
            visorId, dono.getId(), StatusRelacionamento.ACEITO);
  }

  private String mensagemListaPrivada(Usuario dono) {
    VisibilidadeSeguidores visibilidade = dono.getVisibilidade();

    if (visibilidade == VisibilidadeSeguidores.SO_AMIGOS) {
      return "Esta lista só é visível para amigos.";
    }

    return "Esta lista é privada.";
  }

  /**
   * Segue nos dois sentidos, sem duplicar.
   *
   * <p>Chamado ao aceitar a amizade (viram seguidores mútuos) e no
   * cadastro de quem já chega com amigos.
   */
  private void seguirSilenciosamente(Usuario de, Usuario para) {
    if (de.getId().equals(para.getId())) return;
    if (usuarioSegueRepository.existe(de.getId(), para.getId())) return;

    UsuarioSegue follow = new UsuarioSegue();
    follow.setSeguidor(de);
    follow.setSeguindo(para);
    usuarioSegueRepository.save(follow);
  }

  private Usuario buscarUsuario(Long usuarioId) {
    return usuarioRepository
        .findById(usuarioId)
        .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));
  }
}
