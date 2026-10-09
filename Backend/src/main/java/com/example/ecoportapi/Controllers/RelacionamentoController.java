package com.example.ecoportapi.Controllers;


import com.example.ecoportapi.DTOs.Request.AmizadeRespostaDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.Services.RelacionamentoService;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.apache.tomcat.util.net.openssl.ciphers.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/usuarios/eu")
public class RelacionamentoController {

    private final RelacionamentoService relacionamentoService;

    public RelacionamentoController(RelacionamentoService relacionamentoService) {
        this.relacionamentoService = relacionamentoService;
    }

    @GetMapping("/pesquisar")
    public ResponseEntity<?> PesquisarPessoas(
            @RequestParam(value = "q") String termo
    ){
        List<UsuarioDTO> usuarios = relacionamentoService.PesquisarPessoas(termo);

        return ResponseEntity.ok().build();
    }




    @PostMapping("/amizade/{usuarioAlvoId}")
    public ResponseEntity<?> EnviarPedidoAmizade(
            @PathVariable Long usuarioAlvoId,
            Authentication authentication
    ){
        relacionamentoService.EnviarPedidoAmizade(authentication,usuarioAlvoId);

        return ResponseEntity.ok().build();
    }

    @DeleteMapping("amizade/{usuarioAlvoId}")
    public ResponseEntity<?> DesfazerAmizade(
            @PathVariable Long usuarioAlvoId,
            Authentication authentication
    ){
        relacionamentoService.DesfazerAmizade(authentication,usuarioAlvoId);

        return ResponseEntity.ok().build();
    }

    @PostMapping("/amizade/responder/{pedidoAlvoId}")
    public ResponseEntity<?> ResponderPedidoAmizade(
            @RequestBody AmizadeRespostaDTO amizadeRespostaDTO,
            @PathVariable Long pedidoAlvoId,
            Authentication authentication
    ){

        relacionamentoService.ResponderPedidoAmizade(
                authentication,
                amizadeRespostaDTO,
                pedidoAlvoId
        );

        return ResponseEntity.ok().build();
    }

    @GetMapping("/amizade/pedidos")
    public ResponseEntity<?> ListarPedidosDeAmizade(
            Authentication authentication
    ){

        relacionamentoService.ListarPedidosAmizade(authentication);
        return ResponseEntity.ok().build();
    }




    @PostMapping("/seguidores/{usuarioAlvoId}")
    public ResponseEntity<?> EnviarPedidoSeguidor(
            @PathVariable Long usuarioAlvoId,
            Authentication authentication
    ){

        relacionamentoService.EnviarPedidoSeguido(authentication,usuarioAlvoId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/seguidores/{usuarioAlvoId}")
    public ResponseEntity<?> ResponderPedidoSeguidor(
            @PathVariable Long usuarioAlvoId,
            Authentication authentication
    ){

        relacionamentoService.ResponderPedidoSeguidor(authentication,usuarioAlvoId)
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/seguidores/{usuarioAlvoId}")
    public ResponseEntity<?> PararDeSeguir(
            @PathVariable Long usuarioAlvoId,
            Authentication authentication
    ){

        relacionamentoService.PararDeSeguir(authentication,usuarioAlvoId);
        return ResponseEntity.ok().build();
    }



}
