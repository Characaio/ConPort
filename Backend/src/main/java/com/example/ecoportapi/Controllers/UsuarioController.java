package com.example.ecoportapi.Controllers;

//TRABALHAR DE MANEIRA SERIA NESSA CONTROLLER APÓS A QUARTA-FEIRA

import com.example.ecoportapi.DTOs.Request.PreferenciaUpdateDTO;
import com.example.ecoportapi.Services.AuthService;
import com.example.ecoportapi.Services.MissaoService;
import com.example.ecoportapi.Services.UsuarioService;
import org.apache.tomcat.util.net.openssl.ciphers.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/usuarios/eu")
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final MissaoService missaoService;

    public UsuarioController(UsuarioService usuarioService, MissaoService missaoService) {
        this.usuarioService = usuarioService;
        this.missaoService = missaoService;
    }

    @GetMapping("")
    public ResponseEntity<?> PegarUsuario(Authentication authentication){
        return ResponseEntity.ok(usuarioService.pegarUsuario(authentication));
    }

    @PostMapping("/eu/missoes/gerar")
    public ResponseEntity<?> GerarMissoes(Authentication authentication){
        return ResponseEntity.ok(missaoService.GerarMissoes(authentication));
    }

    @GetMapping("/eu/preferencias")
    public ResponseEntity<?> PegarPreferencias(Authentication authentication){
        return ResponseEntity.ok(usuarioService.PegarPreferencia(authentication));
    }

    @PutMapping("/eu/preferencia")
    public ResponseEntity<?> AtualizarPreferencia(
            Authentication authentication,
            @RequestBody PreferenciaUpdateDTO preferenciaUpdateDTO
    ){
        return ResponseEntity.ok(
                usuarioService.AtualizarPreferencia(preferenciaUpdateDTO,authentication)
        );
    }


}
