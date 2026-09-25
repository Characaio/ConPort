package com.example.ecoportapi.Controllers;

//Começar a trabalhar

import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Services.ReportService;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/{id}/completo")
    public ResponseEntity<?> PegarReportCompleto(@PathVariable Long id){
        return ResponseEntity.ok(reportService.PegarReportCompleto(id));
    }
    @GetMapping("/{id}/resumido")
    public ResponseEntity<?> PegarReportResumido(@PathVariable Long id){
        return ResponseEntity.ok(reportService.PegarReportResumido(id));
    }

    @PostMapping("/{id}/analise")
    public ResponseEntity<?> PostarAnalise(
            @PathVariable Long id,
            @RequestBody ReportStatusAnalise reportStatusAnalise
    ){
        return ResponseEntity.ok(reportService.PostarAnalise(id, reportStatusAnalise));
    }


}
