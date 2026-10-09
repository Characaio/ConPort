package com.example.ecoportapi.Services;

import com.example.ecoportapi.DTOs.Request.PreferenciaUpdateDTO;
import com.example.ecoportapi.DTOs.Request.UsuarioCreateDTO;
import com.example.ecoportapi.DTOs.Response.PreferenciaDTO;
import com.example.ecoportapi.Exceptions.PreferenciaNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioJaCadastrado;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Models.UsuarioPreferencia;
import com.example.ecoportapi.Repositories.MissaoRepository;
import com.example.ecoportapi.Repositories.UsuarioPreferenciaRepository;
import jakarta.transaction.Transactional;
import org.apache.tomcat.util.net.openssl.ciphers.Authentication;
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
    private final UsuarioPreferenciaRepository usuarioPreferenciaRepository;
    private final ImagemService imagemService;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository, MissaoRepository missaoRepository, UsuarioPreferenciaRepository usuarioPreferenciaRepository, ImagemService imagemService, PasswordEncoder passwordEncoder){
        this.usuarioRepository = usuarioRepository;
        this.missaoRepository = missaoRepository;
        this.usuarioPreferenciaRepository = usuarioPreferenciaRepository;
        this.imagemService = imagemService;
        this.passwordEncoder = passwordEncoder;
    }

    public UsuarioDTO pegarUsuario(Authentication authentication){
        Usuario usuario = usuarioRepository.findByEmail(authentication.name())
                .orElseThrow(
                        () -> new UsuarioNaoEncontrado("Usuario não encontrado")
                );

        return new UsuarioDTO(usuario);
    }

    @Transactional
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

        Usuario possivelUsuario = usuarioRepository.findByEmail(usuarioDTO.email()).orElse(
                null
        );

        if (possivelUsuario != null){
            throw new UsuarioJaCadastrado("Usuario ja cadastrado");
        }

        UsuarioPreferencia usuarioPreferencia = new UsuarioPreferencia();

        usuarioPreferencia.setUsuarioDono(usuario);

        usuarioPreferenciaRepository.save(usuarioPreferencia);

        return usuarioRepository.save(usuario);
    }

    public void CalcularReputação(){
        return;
    }

    public PreferenciaDTO PegarPreferencia(Authentication authentication){
        String email = authentication.name();

        Usuario usuario = usuarioRepository.findByEmail(email).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuario não encontrado")
        );

        UsuarioPreferencia preferencia = usuarioPreferenciaRepository.findByUsuarioDono_Id(usuario.getId())
                .orElseThrow(
                        () -> new PreferenciaNaoEncontrada("Preferencia não encontrada")
                );

        return new PreferenciaDTO(preferencia);

    }

    public PreferenciaDTO AtualizarPreferencia(
            PreferenciaUpdateDTO preferenciaUpdateDTO,
            Authentication authentication
    ){
        String email = authentication.name();

        Usuario usuario = usuarioRepository.findByEmail(email).orElseThrow(
                () -> new UsuarioNaoEncontrado("Usuario não encontrado")
        );

        UsuarioPreferencia preferencia = usuarioPreferenciaRepository.findByUsuarioDono_Id(usuario.getId())
                .orElseThrow(
                        () -> new PreferenciaNaoEncontrada("Preferencia não encontrada")
                );

        preferencia.setPerfilPublico(preferenciaUpdateDTO.perfilPublico());
        preferencia.setPermiteSolicitacoes(preferenciaUpdateDTO.permiteSolicitacoes());
        preferencia.setNotificarNoApp(preferenciaUpdateDTO.notficarEmail());
        preferencia.setCompartilharLocalizacao(preferenciaUpdateDTO.compartilharLocalizacao());
        preferencia.setDadosDeUsoAnonimo(preferenciaUpdateDTO.dadosDeUsoAnonimo());
        preferencia.setVisibilidade(preferenciaUpdateDTO.visibilidadeSeguidores());

        return new PreferenciaDTO(
                usuarioPreferenciaRepository.save(preferencia)
        );
    }
}


