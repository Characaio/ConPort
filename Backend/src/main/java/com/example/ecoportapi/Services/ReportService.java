package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class ReportService {

    private final ReportRepository reportRepository;
    private final UnidadeRepository unidadeRepository;
    private final UsuarioRepository usuarioRepository;

    public ReportService(ReportRepository reportRepository, UnidadeRepository unidadeRepository, UsuarioRepository usuarioRepository) {
        this.reportRepository = reportRepository;
        this.unidadeRepository = unidadeRepository;
        this.usuarioRepository = usuarioRepository;
    }

    public ReportExpandidoDTO PegarReportCompleto(Long id){
        return reportRepository.PegarReportCompleto(id);
    }

    public ResponseEntity<?> PostarReport(ReportCreateDTO reportDTO){
        Report report = new Report();

        UnidadeDeConservacao unidade = unidadeRepository.findById(reportDTO.UnidadeId())
                .orElseThrow();

        Usuario usuario = usuarioRepository.findById(reportDTO.UsuarioId())
                .orElseThrow();

        report.setUnidade(unidade);
        report.setUsuario(usuario);
        report.setDescricao(reportDTO.Descricao());
        report.setTipo(TipoDeIncidente.StringParaTipo(reportDTO.Tipo()));
        report.setDataDoOcorrido(LocalDate.now());
        report.setLocal(reportDTO.Local());
        report.setImagensRelacionadas(reportDTO.ImagensAnexadas());
        report.setStatus(StatusReport.PENDENTE);

        reportRepository.save(report);

        return ResponseEntity.status(HttpStatus.CREATED).body(reportRepository.save(report));



    }
}
