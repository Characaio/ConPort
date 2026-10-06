package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.Especie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EspecieRepository extends JpaRepository<Especie,Long> {


}
