package com.example.ecoportapi.Services;

import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetaislService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    public CustomUserDetaislService(UsuarioRepository usuarioRepository){
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        Usuario usuario = usuarioRepository
                .findByEmail(email)
                .orElseThrow(
                        () -> new UsernameNotFoundException("Usuario não encontrado")
                );
        return User
                .withUsername(usuario.getEmail())
                .password(usuario.getSenha())
                .build();
    }
}
