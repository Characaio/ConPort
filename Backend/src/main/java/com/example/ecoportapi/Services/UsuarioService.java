package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.LoginDTO;
import com.example.ecoportapi.DTOs.Request.SignupDTO;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusMissao;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.Repositories.UsuarioRepository;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final MissaoRepository missaoRepository;
    public UsuarioService(UsuarioRepository usuarioRepository, MissaoRepository missaoRepository){
        this.usuarioRepository = usuarioRepository;
        this.missaoRepository = missaoRepository;
    }

    public UsuarioDTO pegarUsuario(Long usuarioId){
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );
        return new UsuarioDTO(usuario);
    }

    public void CalcularReputação(){

    }

    public ResponseEntity<?> Signup(SignupDTO signupDTO){
        Usuario usuario = new Usuario();

        if (usuarioRepository.existsByEmailAndSenha(signupDTO.email(), signupDTO.senha())){
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

        usuarioRepository.save(usuario);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    public ResponseEntity<?> Login(LoginDTO loginDTO){
        Usuario usuario = usuarioRepository
                .findByEmailAndSenha(loginDTO.email(), loginDTO.senha()).orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );
        return ResponseEntity.ok(new UsuarioDTO(usuario));
    }
}
