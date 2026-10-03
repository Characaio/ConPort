package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.DTOs.Request.LoginDTO;
import com.example.ecoportapi.DTOs.Request.SignupDTO;
import com.example.ecoportapi.DTOs.Response.AvatarResponseDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioResumoDTO;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusRelacionamento;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.UsuarioRelacionamento;
import com.example.ecoportapi.Repositories.MissaoRepository;
import com.example.ecoportapi.Repositories.RelacionamentoRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import java.io.IOException;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UsuarioService {

  private final UsuarioRepository usuarioRepository;
  private final MissaoRepository missaoRepository;
  private final RelacionamentoRepository relacionamentoRepository;
  private final ImagemService imagemService;

  public UsuarioService(
      UsuarioRepository usuarioRepository,
      MissaoRepository missaoRepository,
      RelacionamentoRepository relacionamentoRepository,
      ImagemService imagemService) {
    this.usuarioRepository = usuarioRepository;
    this.missaoRepository = missaoRepository;
    this.relacionamentoRepository = relacionamentoRepository;
    this.imagemService = imagemService;
  }

  public void CalcularReputação() {}

  public ResponseEntity<?> Signup(SignupDTO signupDTO) {
    Usuario usuario = new Usuario();

    if (usuarioRepository.existsByEmailAndSenha(signupDTO.email(), signupDTO.senha())) {
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
    String apelido = signupDTO.apelido() == null ? null : signupDTO.apelido().trim().toLowerCase();

    if (apelido == null || !apelido.matches("^[a-z0-9_.]{3,24}$")) {
      return ResponseEntity.badRequest()
          .body(
              "Apelido deve ter de 3 a 24 caracteres, "
                  + "apenas letras minúsculas, números, ponto ou _");
    }

    if (usuarioRepository.existsByApelidoIgnoreCase(apelido)) {
      return ResponseEntity.status(HttpStatus.CONFLICT).body("Apelido já em uso");
    }

    usuario.setApelido(apelido);
    usuario.setAvatar(null);
    usuarioRepository.save(usuario);

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  public ResponseEntity<?> Login(LoginDTO loginDTO) {
    Usuario usuario =
        usuarioRepository
            .findByEmailAndSenha(loginDTO.email(), loginDTO.senha())
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));
    return ResponseEntity.ok(new UsuarioDTO(usuario, 0L, 0L));
  }

  // ~ Cae
  public UsuarioDTO pegarUsuario(Long usuarioId) {
    Usuario usuario =
        usuarioRepository
            .findById(usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));
    return new UsuarioDTO(
        usuario,
        usuarioRepository.countSeguidores(usuarioId, StatusRelacionamento.ACEITO),
        usuarioRepository.countSeguindo(usuarioId, StatusRelacionamento.ACEITO));
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

    return usuarioRepository.buscar(usuarioId, limpo, PageRequest.of(0, 20)).stream()
        .map(UsuarioResumoDTO::new)
        .toList();
  }

  public ResponseEntity<?> enviarSolicitacao(Long usuarioId, Long alvoId) {
    if (usuarioId.equals(alvoId)) {
      return ResponseEntity.badRequest().body("Você não pode enviar solicitação para si mesmo");
    }

    usuarioRepository
        .findById(alvoId)
        .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

    var existente = relacionamentoRepository.findBySeguidorIdAndSeguindoId(usuarioId, alvoId);

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

    return ResponseEntity.status(HttpStatus.CREATED).build();
  }

  public ResponseEntity<?> aceitar(Long usuarioId, Long relacaoId) {
    UsuarioRelacionamento relacao =
        relacionamentoRepository
            .findByIdAndSeguindoId(relacaoId, usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Solicitação não encontrada"));

    relacao.setStatus(StatusRelacionamento.ACEITO);
    relacionamentoRepository.save(relacao);

    boolean espelhoExiste =
        relacionamentoRepository
            .findBySeguidorIdAndSeguindoId(
                relacao.getSeguindo().getId(), relacao.getSeguidor().getId())
            .isPresent();

    if (!espelhoExiste) {
      UsuarioRelacionamento espelho = new UsuarioRelacionamento();
      espelho.setSeguidor(relacao.getSeguindo());
      espelho.setSeguindo(relacao.getSeguidor());
      espelho.setStatus(StatusRelacionamento.ACEITO);
      relacionamentoRepository.save(espelho);
    }

    return ResponseEntity.ok().build();
  }

  public ResponseEntity<?> recusar(Long usuarioId, Long relacaoId) {
    UsuarioRelacionamento relacao =
        relacionamentoRepository
            .findByIdAndSeguindoId(relacaoId, usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Solicitação não encontrada"));

    if (relacao.getStatus() == StatusRelacionamento.ACEITO) {
      return ResponseEntity.badRequest().body("Isso é uma amizade, não uma solicitação");
    }

    relacionamentoRepository.delete(relacao);
    return ResponseEntity.ok().build();
  }

  public ResponseEntity<?> removerAmizade(Long usuarioId, Long alvoId) {
    var minha = relacionamentoRepository.findBySeguidorIdAndSeguindoId(usuarioId, alvoId);
    var dele = relacionamentoRepository.findBySeguidorIdAndSeguindoId(alvoId, usuarioId);

    minha.ifPresent(relacionamentoRepository::delete);
    dele.ifPresent(relacionamentoRepository::delete);

    return ResponseEntity.noContent().build();
  }

  public ResponseEntity<?> atualizarAvatar(Long usuarioId, MultipartFile arquivo)
      throws IOException {
    Usuario usuario =
        usuarioRepository
            .findById(usuarioId)
            .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

    ImagemProcessada imagem = imagemService.SalvarImagem(arquivo);
    usuario.setAvatar(imagem.NomeArquivo());
    usuarioRepository.save(usuario);

    return ResponseEntity.ok(new AvatarResponseDTO(imagem.NomeArquivo()));
  }
}
