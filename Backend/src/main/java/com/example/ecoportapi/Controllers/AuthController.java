package com.example.ecoportapi.Controllers;

//TRABALHAR NELE APENAS APÓS ESTABELECER A ESTRUTURA

import com.example.ecoportapi.DTOs.Request.LoginCreateDTO;
import com.example.ecoportapi.DTOs.Request.RefreshTokenDTO;
import com.example.ecoportapi.DTOs.Request.UsuarioCreateDTO;
import com.example.ecoportapi.Models.RefreshToken;
import com.example.ecoportapi.Services.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/usuarios/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    public ResponseEntity<?> Signup(
            @RequestPart("usuarioDTO") UsuarioCreateDTO usuarioDTO ,
            @RequestPart("avatarImagem") MultipartFile avatarImagem
            ) throws IOException {
        return ResponseEntity.ok(
                authService.Signup(usuarioDTO,avatarImagem)
        );
    }

    @PostMapping("/login")
    public ResponseEntity<?> Login(
            @RequestBody LoginCreateDTO loginDTO
    ){
        return ResponseEntity.ok(authService.Login(loginDTO));
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> Refresh(
            @RequestBody RefreshTokenDTO request
            ){
        return ResponseEntity.ok(authService.Refresh(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> Logout(
            @RequestBody RefreshTokenDTO refreshTokenDTO
            ){
        return authService.Logout(refreshTokenDTO);
    }
}
