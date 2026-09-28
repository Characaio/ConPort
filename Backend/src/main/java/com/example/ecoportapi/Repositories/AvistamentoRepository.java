package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Aviso;
import com.example.ecoportapi.Models.Avistamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AvistamentoRepository extends JpaRepository<Avistamento,Long> {
}
