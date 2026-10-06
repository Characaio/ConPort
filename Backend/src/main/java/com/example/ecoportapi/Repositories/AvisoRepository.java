package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Aviso;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvisoRepository extends JpaRepository<Aviso,Long> {

    Page<Aviso> findByUnidadeId(Long unidadeId, Pageable pageable);
}
