package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.UsuarioPreferencia;
import org.springframework.data.jpa.repository.JpaRepository;

import javax.swing.text.html.Option;
import java.util.Optional;

public interface UsuarioPreferenciaRepository extends JpaRepository<UsuarioPreferencia,Long> {

    Optional<UsuarioPreferencia> findByUsuarioDono_Id(Long usuarioId);
}
