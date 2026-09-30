package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Aviso;
import com.example.ecoportapi.Models.Avistamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvistamentoRepository extends JpaRepository<Avistamento,Long> {

    List<Avistamento> findAllByUsuario_Id(Long usuarioId);
    List<Avistamento> findAllByUnidade_Id(Long unidadeId);
}
