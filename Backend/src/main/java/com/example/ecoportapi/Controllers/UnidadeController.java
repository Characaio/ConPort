package com.example.ecoportapi.Controllers;

//Começar o trabalho

import com.example.ecoportapi.DTOs.Request.AvisoCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusGeralDTO;
import com.example.ecoportapi.DTOs.Response.UnidadeStatusPrincipalDTO;
import com.example.ecoportapi.Services.ReportService;
import com.example.ecoportapi.Services.UnidadeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;



///URL/unidade/5/statusPrincipal
@RestController
@RequestMapping("/unidade")
public class UnidadeController {

    private final UnidadeService unidadeService;
    private final ReportService reportService;
    public UnidadeController(UnidadeService unidadeService, ReportService reportService) {
        this.unidadeService = unidadeService;
        this.reportService = reportService;
    }

    @GetMapping("/{id}/statusPrincipal")
    public ResponseEntity<?> PegarStatus(@PathVariable Long id){
        return ResponseEntity.ok(unidadeService.PegarStatusPrincipal(id));
    }

    @GetMapping("/{id}/statusGeral")
    public ResponseEntity<?> PegarStatusGeral(@PathVariable Long id){
        return ResponseEntity.ok(unidadeService.PegarStatusGeral(id));
    }

    @GetMapping("/{id}/reports")
    public ResponseEntity<?> PegarReportsDaUnidade(@PathVariable Long id){
        return ResponseEntity.ok(unidadeService.PegarReportsDaUnidade(id));
    }
    @PostMapping(
            value = "/{id}/report",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<?> PostarReport(
            @RequestPart("reportDTO") ReportCreateDTO reportDTO,
            @RequestPart(value = "imagens",required = false) List<MultipartFile> imagens,
            @PathVariable Long id
    ) throws IOException {
        return reportService.PostarReport(reportDTO,imagens,id);
    }






}
