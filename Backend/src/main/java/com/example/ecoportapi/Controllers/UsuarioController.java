package com.example.ecoportapi.Controllers;

//TRABALHAR DE MANEIRA SERIA NESSA CONTROLLER APÓS A QUARTA-FEIRA

import com.example.ecoportapi.Services.MissaoService;
import com.example.ecoportapi.Services.UsuarioService;
import org.apache.catalina.connector.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final MissaoService missaoService;

    public UsuarioController(UsuarioService usuarioService, MissaoService missaoService) {
        this.usuarioService = usuarioService;
        this.missaoService = missaoService;
    }

    @PostMapping("/{id}/missoes/gerar")
    public ResponseEntity<?> GerarMissoes(@PathVariable Long id){
        return ResponseEntity.ok("oq caralhas é pra ter aqui seu fdp");
    }

    @GetMapping("{/{id}")
    public ResponseEntity<?> PegarUsuario(@PathVariable Long id){
        return ResponseEntity.ok(usuarioService.pegarUsuario(id));
    }
}
