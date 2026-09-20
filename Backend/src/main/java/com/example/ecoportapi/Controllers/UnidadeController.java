package com.example.ecoportapi.Controllers;

//Começar o trabalho

import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusGeralDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusPrincipalDTO;
import com.example.ecoportapi.Services.UnidadeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


//http://localhost:8080/unidade/5/statusPrincipal
@RestController
@RequestMapping("/unidade")
public class UnidadeController {

    @Autowired
    private final UnidadeService unidadeService;

    public UnidadeController(UnidadeService unidadeService) {
        this.unidadeService = unidadeService;
    }

    @GetMapping("/{id}/statusPrincipal")
    public UnidadeStatusPrincipalDTO PegarStatus(@PathVariable Long id){
        return unidadeService.PegarStatusPrincipal(id);
    }

    @GetMapping("/{id}/statusGeral")
    public UnidadeStatusGeralDTO PegarStatusGeral(@PathVariable Long id){
        return unidadeService.PegarStatusGeral(id);
    }

    @GetMapping("/{id}/reports")
    public List<ReportResumidoDTO> PegarReportsDaUnidade(@PathVariable Long id){
        return unidadeService.PegarReportsDaUnidade(id);
    }


}
