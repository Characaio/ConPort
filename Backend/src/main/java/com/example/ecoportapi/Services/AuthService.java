package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.LoginCreateDTO;
import com.example.ecoportapi.DTOs.Request.RefreshTokenDTO;
import com.example.ecoportapi.DTOs.Request.UsuarioCreateDTO;
import com.example.ecoportapi.DTOs.Response.RefreshTokenCriadoDTO;
import com.example.ecoportapi.DTOs.Response.TokenDTO;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.Exceptions.RefreshTokenNaoEncontrado;
import com.example.ecoportapi.Exceptions.TokenInvalido;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.RefreshToken;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.RefreshTokenRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import com.example.ecoportapi.Security.JwtService;
import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Ref;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;

@Service
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final SecureRandom secureRandom;
    private final UsuarioService usuarioService;

    public AuthService(
            UsuarioRepository usuarioRepository,
            RefreshTokenRepository refreshTokenRepository,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            UserDetailsService userDetailsService,
            UsuarioService usuarioService
    ){
        this.usuarioRepository = usuarioRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.userDetailsService = userDetailsService;
        this.secureRandom = new SecureRandom();
        this.usuarioService = usuarioService;
    }

    private String GerarHash(String token) {

        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            byte[] hash = digest.digest(
                    token.getBytes(StandardCharsets.UTF_8)
            );

            return HexFormat.of().formatHex(hash);

        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(
                    "SHA-256 não disponível",
                    e
            );
        }
    }

    private String GerarAccessToken(LoginCreateDTO loginCreateDTO){

        Authentication authentication =
                authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                loginCreateDTO.email(),
                                loginCreateDTO.senha()
                        )
                );

        UserDetails userDetails =
                (UserDetails) authentication.getPrincipal();

        assert userDetails != null;
        return jwtService.GenerateToken(userDetails);
    }

    private String GerarAccessToken(String email){

        UserDetails userDetails =
                userDetailsService.loadUserByUsername(email);

        return jwtService.GenerateToken(userDetails);
    }

    private String GerarTokenAleatorio(){


        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes);
    }

    private RefreshTokenCriadoDTO GerarRefreshToken(Usuario usuario){

        String token = GerarTokenAleatorio();

        String refreshTokenHash = GerarHash(token);

        Instant criadoEm = Instant.now();
        Instant expiraEm = criadoEm.plus(30, ChronoUnit.DAYS);

        RefreshToken refreshToken = new RefreshToken();

        refreshToken.setUsuario(usuario);
        refreshToken.setCriadoEm(criadoEm);
        refreshToken.setExpiraEm(expiraEm);
        refreshToken.setRevogado(false);
        refreshToken.setTokenHash(refreshTokenHash);

        refreshTokenRepository.save(refreshToken);

        return new RefreshTokenCriadoDTO(
                refreshToken,
                token
        );
    }

    public ResponseEntity<?> Logout(RefreshTokenDTO refreshTokenDTO){
        RefreshToken refreshToken = refreshTokenRepository.findByTokenHash(
                GerarHash(refreshTokenDTO.refreshToken())
        ).orElseThrow(
                () -> new RefreshTokenNaoEncontrado("Refresh token não encontrado")
        );

        refreshTokenRepository.delete(refreshToken);

        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Usuario deslogado com sucesso");
    }

    public TokenDTO Signup(UsuarioCreateDTO usuarioDTO, MultipartFile avatarImagem) throws IOException {

        Usuario usuario = usuarioService.CriarUsuario(usuarioDTO,avatarImagem);

        String accessToken = GerarAccessToken(
                new LoginCreateDTO(
                        usuario.getEmail(),
                        usuarioDTO.senha()
                )

        );

        RefreshTokenCriadoDTO refreshToken = GerarRefreshToken(usuario);

        return new TokenDTO(
                accessToken,
                refreshToken.token()
        );
    }

    public TokenDTO Login(LoginCreateDTO loginCreateDTO) {

        String accessToken = GerarAccessToken(loginCreateDTO);

        Usuario usuario = usuarioRepository.findByEmail(loginCreateDTO.email())
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );

        RefreshTokenCriadoDTO refreshToken = GerarRefreshToken(usuario);

        return new TokenDTO(
                accessToken,
                refreshToken.token()
        );
    }

    @Transactional
    public TokenDTO Refresh(RefreshTokenDTO refreshTokenDTO){

        String token = refreshTokenDTO.refreshToken();

        String tokenHash = GerarHash(token);

        RefreshToken refreshToken = refreshTokenRepository
                .findByTokenHash(tokenHash)
                .orElseThrow(
                        () -> new TokenInvalido("Refresh Token invalido")
                );

        Instant agora = Instant.now();

        if (refreshToken.getExpiraEm().isBefore(agora)){
            refreshToken.setRevogado(true);
            refreshTokenRepository.save(refreshToken);
            throw new TokenInvalido("Refresh token expirado");
        }

        Usuario usuario = refreshToken.getUsuario();

        refreshTokenRepository.delete(refreshToken);

        RefreshTokenCriadoDTO novoRefreshToken = GerarRefreshToken(usuario);

        String accessToken = GerarAccessToken(
                usuario.getEmail()
        );

        return new TokenDTO(
                accessToken,
                novoRefreshToken.token()
        );
    }
}
