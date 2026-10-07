package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.UsuarioCreateDTO;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.MissaoRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.example.ecoportapi.DTOs.Response.UsuarioDTO;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final MissaoRepository missaoRepository;
    private final ImagemService imagemService;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository, MissaoRepository missaoRepository, ImagemService imagemService, PasswordEncoder passwordEncoder){
        this.usuarioRepository = usuarioRepository;
        this.missaoRepository = missaoRepository;
        this.imagemService = imagemService;
        this.passwordEncoder = passwordEncoder;
    }

    public UsuarioDTO pegarUsuario(Long usuarioId){
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );

        return new UsuarioDTO(usuario);
    }

    public Usuario CriarUsuario(UsuarioCreateDTO usuarioDTO, MultipartFile avatarImagem) throws IOException {
        String imagemCaminho = imagemService.SalvarImagem(avatarImagem).NomeArquivo();

        Usuario usuario = new Usuario();

        usuario.setNome(usuarioDTO.username());
        usuario.setDataNasc(usuarioDTO.dataNasc());
        usuario.setEmail(usuarioDTO.email());
        usuario.setSenha(passwordEncoder.encode(usuarioDTO.senha()));
        usuario.setCidade(usuarioDTO.cidade());
        usuario.setEstado(usuarioDTO.estado());
        usuario.setConfiavel(false);
        usuario.setLevel(0);
        usuario.setXP(0);
        usuario.setMoedas(0);
        usuario.setReputacao(0D);
        usuario.setAvatarImagemCaminho(imagemCaminho);

        return usuarioRepository.save(usuario);
    }

    public void CalcularReputação(){
        return;
    }
}


