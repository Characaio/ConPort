package com.example.ecoportapi.Controllers;

//Começar a trabalhar

import com.example.ecoportapi.DTOs.Request.LocalizacaoDTO;
import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.Services.ReportService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/unidade/{unidadeId}/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping()
    public ResponseEntity<?> PegarReportsDaUnidade(@PathVariable Long unidadeId){
        return ResponseEntity.ok(
                reportService.PegarReportsDaUnidade(unidadeId)
        );
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<?> PegarReportCompleto(@PathVariable Long reportId){
        return ResponseEntity.ok(reportService.PegarReportCompleto(reportId));
    }

    @PostMapping("/{reportId}/analise")
    public ResponseEntity<?> PostarAnalise(
            @PathVariable Long reportId,
            @RequestBody ReportStatusAnalise reportStatusAnalise
    ){
        return ResponseEntity.ok(reportService.PostarAnalise(reportId, reportStatusAnalise));
    }

    @PostMapping(
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<?> PostarReport(
            @RequestPart("reportDTO") ReportCreateDTO reportDTO,
            @RequestPart(value="localizacao",required = false) LocalizacaoDTO localizacaoDTO,
            @RequestPart(value = "imagens",required = false) List<MultipartFile> imagens,
            @PathVariable Long unidadeId
    ) throws IOException {
        return reportService.PostarReport(reportDTO,localizacaoDTO,imagens,unidadeId);
    }


}
