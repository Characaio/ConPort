package com.example.ecoportapi.Repositories;

import com.example.ecoportapi.Models.SupervisorDeUnidade;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupervisorRepository extends JpaRepository<SupervisorDeUnidade,Long> {
}
