package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.DTOs.Response.*;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UnidadeRepository extends JpaRepository<UnidadeDeConservacao,Long> {
}
