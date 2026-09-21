package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Exceptions.ReportNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
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
import java.time.LocalDateTime;

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
    public ReportResumidoDTO PegarReportResumido(Long id){
        return reportRepository.PegarReportResumido(id);
    }

    public ResponseEntity<?> PostarReport(ReportCreateDTO reportDTO){
        Report report = CriarReport(reportDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(reportRepository.save(report));
    }

    public ResponseEntity<?> PostarAnalise(Long id, ReportStatusAnalise reportStatusAnalise){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Não Encontrado"));

        report.setStatus(StatusReport.StringParaTipo(reportStatusAnalise.Status()));
        report.setDataDaAnalisa(LocalDateTime.now());
        report.setSupervisor(null);
        reportRepository.save(report);

        return ResponseEntity.ok().build();
    }
    private Report CriarReport(ReportCreateDTO reportDTO){
        Report report = new Report();
        UnidadeDeConservacao unidade = unidadeRepository.findById(reportDTO.UnidadeId())
                .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(reportDTO.UsuarioId())
                .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

        report.setUnidade(unidade);
        report.setUsuario(usuario);
        report.setDescricao(reportDTO.Descricao());
        report.setTipo(TipoDeIncidente.StringParaTipo(reportDTO.Tipo()));
        report.setDataDoOcorrido(LocalDateTime.parse(reportDTO.DataDoOcorrido()));
        report.setLocal(reportDTO.Local());
        report.setImagensAnexadas(reportDTO.ImagensAnexadas());
        report.setStatus(StatusReport.PENDENTE);

        return report;
    }
}
