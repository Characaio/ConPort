package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}
