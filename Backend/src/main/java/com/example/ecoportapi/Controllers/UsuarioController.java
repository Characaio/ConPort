package com.example.ecoportapi.Controllers;

// TRABALHAR DE MANEIRA SERIA NESSA CONTROLLER APÓS A QUARTA-FEIRA
// sergia* ~ Cae

import com.example.ecoportapi.DTOs.Request.AtualizarPerfilDTO;
import com.example.ecoportapi.DTOs.Request.LoginDTO;
import com.example.ecoportapi.DTOs.Request.SignupDTO;
import com.example.ecoportapi.DTOs.Request.VisibilidadeDTO;
import com.example.ecoportapi.Services.ReportService;
import com.example.ecoportapi.Services.UsuarioService;
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

  @GetMapping("/{id}")
  public ResponseEntity<?> PegarUsuario(
      @PathVariable Long id, @RequestParam(required = false) Long visorId) {
    // visorId diz de quem é o ponto de vista: é ele que define se os botões
    // "seguir" e "adicionar amigo" aparecem ativos.
    // ATENÇÃO: sem autenticação, o visor também vem por query string.
    return ResponseEntity.ok(usuarioService.pegarUsuario(id, visorId));
  }

  /*
  @PostMapping
  public ResponseEntity<?> Signup(
          @RequestBody SignupDTO signupDTO
          ){
      return usuarioService.Signup(signupDTO);
  }
  @PostMapping
  public ResponseEntity<?> Login(
          @RequestBody LoginDTO loginDTO
  ){
      return usuarioService.Login(loginDTO);
  }
  */

  // As rotas de autenticação ficam em /usuarios/login e /usuarios/signup,
  // que são as URLs que o frontend já chama.
  @PostMapping("/signup")
  public ResponseEntity<?> Signup(@RequestBody SignupDTO signupDTO) {
    return usuarioService.Signup(signupDTO);
  }

  @PostMapping("/login")
  public ResponseEntity<?> Login(@RequestBody LoginDTO loginDTO) {
    return usuarioService.Login(loginDTO);
  }

  @GetMapping("/{id}/reports")
  public ResponseEntity<?> ListarMeusReports(@PathVariable Long id) {
    // ATENÇÃO: sem autenticação, a lista vem por id na URL.
    // Substituir pelo usuario logado quando existir token.
    return ResponseEntity.ok(reportService.PegarReportsDoUsuario(id));
  }

  @GetMapping("/{id}/amigos")
  public ResponseEntity<?> ListarAmigos(@PathVariable Long id) {
    return ResponseEntity.ok(usuarioService.listarAmigos(id));
  }

  @GetMapping("/{id}/solicitacoes")
  public ResponseEntity<?> ListarSolicitacoes(@PathVariable Long id) {
    return ResponseEntity.ok(usuarioService.listarSolicitacoes(id));
  }

  @GetMapping("/buscar")
  public ResponseEntity<?> Buscar(
      @RequestParam String termo, @RequestParam(required = false) Long usuarioId) {
    // ATENÇÃO: sem autenticação, quem busca se identifica por query string.
    // Substituir pelo usuario logado quando existir token.
    return ResponseEntity.ok(usuarioService.buscar(usuarioId, termo));
  }

  @PostMapping("/{id}/amizade/{alvoId}")
  public ResponseEntity<?> EnviarSolicitacao(
      @PathVariable Long id, @PathVariable Long alvoId) {
    return usuarioService.enviarSolicitacao(id, alvoId);
  }

  @PostMapping("/{id}/aceitar/{relacaoId}")
  public ResponseEntity<?> Aceitar(@PathVariable Long id, @PathVariable Long relacaoId) {
    return usuarioService.aceitar(id, relacaoId);
  }

  @PostMapping("/{id}/recusar/{relacaoId}")
  public ResponseEntity<?> Recusar(@PathVariable Long id, @PathVariable Long relacaoId) {
    return usuarioService.recusar(id, relacaoId);
  }

  @DeleteMapping("/{id}/amizade/{alvoId}")
  public ResponseEntity<?> RemoverAmigo(@PathVariable Long id, @PathVariable Long alvoId) {
    return usuarioService.removerAmizade(id, alvoId);
  }

  // ============================================================
  // SEGUIR
  // ============================================================
  //
  // Estas quatro rotas são o "seguir" sem pedido. Ficaram em /seguindo para
  // não se confundirem com o pedido de amizade, que até pouco ocupava
  // /seguir/{alvoId}.

  @PostMapping("/{id}/seguindo/{alvoId}")
  public ResponseEntity<?> Seguir(@PathVariable Long id, @PathVariable Long alvoId) {
    return usuarioService.seguir(id, alvoId);
  }

  @DeleteMapping("/{id}/seguindo/{alvoId}")
  public ResponseEntity<?> DeixarDeSeguir(
      @PathVariable Long id, @PathVariable Long alvoId) {
    return usuarioService.deixarDeSeguir(id, alvoId);
  }

  @GetMapping("/{id}/seguindo")
  public ResponseEntity<?> ListarSeguindo(
      @PathVariable Long id, @RequestParam(required = false) Long visorId) {
    return usuarioService.listarSeguindo(id, visorId);
  }

  @GetMapping("/{id}/seguidores")
  public ResponseEntity<?> ListarSeguidores(
      @PathVariable Long id, @RequestParam(required = false) Long visorId) {
    return usuarioService.listarSeguidores(id, visorId);
  }

  @PutMapping("/{id}/privacidade")
  public ResponseEntity<?> AtualizarPrivacidade(
      @PathVariable Long id, @RequestBody VisibilidadeDTO dto) {
    return usuarioService.atualizarVisibilidade(id, dto);
  }

  @PostMapping("/{id}/avatar")
  public ResponseEntity<?> AtualizarAvatar(
      @PathVariable Long id, @RequestParam("file") MultipartFile file) throws IOException {
    return usuarioService.atualizarAvatar(id, file);
  }

  @DeleteMapping("/{id}/avatar")
  public ResponseEntity<?> RemoverAvatar(@PathVariable Long id) {
    return usuarioService.removerAvatar(id);
  }

  // ATENÇÃO: sem autenticação, a edição também é pelo id da URL.
  // Substituir pelo usuario logado quando existir token.
  @PutMapping("/{id}")
  public ResponseEntity<?> AtualizarPerfil(
      @PathVariable Long id, @RequestBody AtualizarPerfilDTO dto) {
    return usuarioService.atualizarPerfil(id, dto);
  }
}
