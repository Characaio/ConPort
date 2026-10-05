package com.example.ecoportapi.Controllers;

// TRABALHAR DE MANEIRA SERIA NESSA CONTROLLER APÓS A QUARTA-FEIRA
// sergia* ~ Cae

import com.example.ecoportapi.Annotations.ExigeSessao;
import com.example.ecoportapi.DTOs.Request.AtualizarPerfilDTO;
import com.example.ecoportapi.DTOs.Request.AtualizarPreferenciasDTO;
import com.example.ecoportapi.DTOs.Request.ExcluirContaDTO;
import com.example.ecoportapi.DTOs.Request.LoginDTO;
import com.example.ecoportapi.DTOs.Request.SignupDTO;
import com.example.ecoportapi.DTOs.Request.VisibilidadeDTO;
import com.example.ecoportapi.Services.ReportService;
import com.example.ecoportapi.Services.SessaoInterceptor;
import com.example.ecoportapi.Services.UsuarioService;
import com.example.ecoportapi.Models.Usuario;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

  private final UsuarioService usuarioService;
  private final ReportService reportService;

  public UsuarioController(UsuarioService usuarioService, ReportService reportService) {
    this.usuarioService = usuarioService;
    this.reportService = reportService;
  }

  // ============================================================
  // PÚBLICAS
  //
  // Não exigem token: quem não tem conta precisa conseguir ver perfil de
  // quem tem, e o app tem modo visitante.
  // ============================================================

  /** Perfil de alguém. O "quem está vendo" vem do token, se houver. */
  @GetMapping("/{id}")
  public ResponseEntity<?> PegarUsuario(@PathVariable Long id, HttpServletRequest request) {
    Usuario visitante = SessaoInterceptor.usuarioDaRequisicao(request);

    return ResponseEntity.ok(usuarioService.pegarUsuario(id, visitante == null ? null : visitante.getId()));
  }

  /** Busca pública: é o que a tela "Buscar usuário" usa antes de logar. */
  @GetMapping("/buscar")
  public ResponseEntity<?> Buscar(
      @RequestParam String termo, HttpServletRequest request) {
    Usuario visitante = SessaoInterceptor.usuarioDaRequisicao(request);

    return ResponseEntity.ok(usuarioService.buscar(visitante == null ? null : visitante.getId(), termo));
  }

  /** Listas de seguidores/seguindo: quem decide se abre é a visibilidade. */
  @GetMapping("/{id}/seguindo")
  public ResponseEntity<?> ListarSeguindo(@PathVariable Long id, HttpServletRequest request) {
    Usuario visitante = SessaoInterceptor.usuarioDaRequisicao(request);

    return usuarioService.listarSeguindo(id, visitante == null ? null : visitante.getId());
  }

  @GetMapping("/{id}/seguidores")
  public ResponseEntity<?> ListarSeguidores(@PathVariable Long id, HttpServletRequest request) {
    Usuario visitante = SessaoInterceptor.usuarioDaRequisicao(request);

    return usuarioService.listarSeguidores(id, visitante == null ? null : visitante.getId());
  }

  @PostMapping("/signup")
  public ResponseEntity<?> Signup(@RequestBody SignupDTO signupDTO) {
    return usuarioService.Signup(signupDTO);
  }

  @PostMapping("/login")
  public ResponseEntity<?> Login(@RequestBody LoginDTO loginDTO) {
    return usuarioService.Login(loginDTO);
  }

  // ============================================================
  // DA SESSÃO
  //
  // Aqui o usuário NÃO vem da URL: vem do token. Por isso o caminho é
  // "/eu" e não "/{id}" — não existe mais como pedir a conta de outra
  // pessoa com o id trocado.
  // ============================================================

  @GetMapping("/eu")
  @ExigeSessao
  public ResponseEntity<?> MinhaConta(HttpServletRequest request) {
    return ResponseEntity.ok(usuarioService.minhaConta(euId(request)));
  }

  @PostMapping("/logout")
  @ExigeSessao
  public ResponseEntity<?> Logout(HttpServletRequest request) {
    return usuarioService.Logout(SessaoInterceptor.tokenDaRequisicao(request));
  }

  /** "Sair de todos os lugares": revoga as outras sessões da conta. */
  @PostMapping("/logout-em-todos-os-lugares")
  @ExigeSessao
  public ResponseEntity<?> LogoutEmTodosOsLugares(HttpServletRequest request) {
    return usuarioService.LogoutDeTodosOsLugares(euId(request));
  }

  @PutMapping("/eu")
  @ExigeSessao
  public ResponseEntity<?> AtualizarMeuPerfil(
      @RequestBody AtualizarPerfilDTO dto, HttpServletRequest request) {
    return usuarioService.atualizarPerfil(euId(request), dto);
  }

  @PostMapping("/eu/avatar")
  @ExigeSessao
  public ResponseEntity<?> AtualizarAvatar(
      @RequestParam("file") MultipartFile file, HttpServletRequest request) throws IOException {
    return usuarioService.atualizarAvatar(euId(request), file);
  }

  @DeleteMapping("/eu/avatar")
  @ExigeSessao
  public ResponseEntity<?> RemoverAvatar(HttpServletRequest request) {
    return usuarioService.removerAvatar(euId(request));
  }

  @PutMapping("/eu/privacidade")
  @ExigeSessao
  public ResponseEntity<?> AtualizarPrivacidade(
      @RequestBody VisibilidadeDTO dto, HttpServletRequest request) {
    return usuarioService.atualizarVisibilidade(euId(request), dto);
  }

  @GetMapping("/eu/preferencias")
  @ExigeSessao
  public ResponseEntity<?> MinhasPreferencias(HttpServletRequest request) {
    return ResponseEntity.ok(usuarioService.minhasPreferencias(euId(request)));
  }

  /** Atualização parcial: só os campos que vieram no corpo mudam. */
  @PutMapping("/eu/preferencias")
  @ExigeSessao
  public ResponseEntity<?> AtualizarPreferencias(
      @RequestBody AtualizarPreferenciasDTO dto, HttpServletRequest request) {
    return usuarioService.atualizarPreferencias(euId(request), dto);
  }

  /**
   * Apaga a conta. Exige a senha no corpo mesmo com token válido: quem
   * encontrou o aparelho desbloqueado não deve conseguir apagar a conta de
   * quem o deixou aberto.
   */
  @DeleteMapping("/eu")
  @ExigeSessao
  public ResponseEntity<?> ExcluirConta(
      @RequestBody ExcluirContaDTO dto, HttpServletRequest request) {
    return usuarioService.excluirConta(euId(request), dto);
  }

  @GetMapping("/eu/reports")
  @ExigeSessao
  public ResponseEntity<?> ListarMeusReports(HttpServletRequest request) {
    return ResponseEntity.ok(reportService.PegarReportsDoUsuario(euId(request)));
  }

  @GetMapping("/eu/amigos")
  @ExigeSessao
  public ResponseEntity<?> ListarAmigos(HttpServletRequest request) {
    return ResponseEntity.ok(usuarioService.listarAmigos(euId(request)));
  }

  @GetMapping("/eu/solicitacoes")
  @ExigeSessao
  public ResponseEntity<?> ListarSolicitacoes(HttpServletRequest request) {
    return ResponseEntity.ok(usuarioService.listarSolicitacoes(euId(request)));
  }

  @PostMapping("/eu/amizade/{alvoId}")
  @ExigeSessao
  public ResponseEntity<?> EnviarSolicitacao(
      @PathVariable Long alvoId, HttpServletRequest request) {
    return usuarioService.enviarSolicitacao(euId(request), alvoId);
  }

  @DeleteMapping("/eu/amizade/{alvoId}")
  @ExigeSessao
  public ResponseEntity<?> RemoverAmigo(
      @PathVariable Long alvoId, HttpServletRequest request) {
    return usuarioService.removerAmizade(euId(request), alvoId);
  }

  @PostMapping("/eu/aceitar/{relacaoId}")
  @ExigeSessao
  public ResponseEntity<?> Aceitar(
      @PathVariable Long relacaoId, HttpServletRequest request) {
    return usuarioService.aceitar(euId(request), relacaoId);
  }

  @PostMapping("/eu/recusar/{relacaoId}")
  @ExigeSessao
  public ResponseEntity<?> Recusar(
      @PathVariable Long relacaoId, HttpServletRequest request) {
    return usuarioService.recusar(euId(request), relacaoId);
  }

  @PostMapping("/eu/seguir/{alvoId}")
  @ExigeSessao
  public ResponseEntity<?> Seguir(@PathVariable Long alvoId, HttpServletRequest request) {
    return usuarioService.seguir(euId(request), alvoId);
  }

  @DeleteMapping("/eu/seguir/{alvoId}")
  @ExigeSessao
  public ResponseEntity<?> DeixarDeSeguir(
      @PathVariable Long alvoId, HttpServletRequest request) {
    return usuarioService.deixarDeSeguir(euId(request), alvoId);
  }

  /** O usuário da sessão: nunca `null` aqui, o interceptor já barrou o resto. */
  private Long euId(HttpServletRequest request) {
    return SessaoInterceptor.usuarioObrigatorio(request).getId();
  }
}
