package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Exceptions.ReportNaoEncontrado;
import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.Enums.StatusReport;
import com.example.ecoportapi.Models.Enums.TipoDeIncidente;
import com.example.ecoportapi.Models.Report;
import com.example.ecoportapi.Models.SupervisorDeUnidade;
import com.example.ecoportapi.Models.UnidadeDeConservacao;
import com.example.ecoportapi.Models.Usuario;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.SupervisorRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ReportService {

    private final ReportRepository reportRepository;
    private final UnidadeRepository unidadeRepository;
    private final UsuarioRepository usuarioRepository;
    private final SupervisorRepository supervisorRepository;
    private final ImagensService imagensService;

    public ReportService(ReportRepository reportRepository, UnidadeRepository unidadeRepository, UsuarioRepository usuarioRepository, SupervisorRepository supervisorRepository, ImagensService imagensService) {
        this.reportRepository = reportRepository;
        this.unidadeRepository = unidadeRepository;
        this.usuarioRepository = usuarioRepository;
        this.supervisorRepository = supervisorRepository;
        this.imagensService = imagensService;
    }

    public ReportExpandidoDTO PegarReportCompleto(Long id){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Nao Encontrado"));

        return new ReportExpandidoDTO(report);
    }
    public ReportResumidoDTO PegarReportResumido(Long id){
        return reportRepository.PegarReportResumido(id);
    }

    public ResponseEntity<?> PostarReport(
            ReportCreateDTO reportDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = CriarReport(reportDTO,unidadeId);
        if (imagens != null){
            List<String> imagensCaminho = new ArrayList<>();
            for (MultipartFile imagem : imagens){
                String caminho = imagensService.salvarImagem(imagem);
                imagensCaminho.add(caminho);
            }
            report.setImagensAnexadas(imagensCaminho);
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(reportRepository.save(report));
    }

    public ResponseEntity<?> PostarAnalise(Long id, ReportStatusAnalise reportStatusAnalise){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Não Encontrado"));
        SupervisorDeUnidade supervisor = supervisorRepository.findById(reportStatusAnalise.SupervisorId())
                        .orElseThrow(() -> new SupervisorNaoEncontrado("Supervisor Não Encontrado"));
        report.setStatus(StatusReport.StringParaTipo(reportStatusAnalise.Status()));
        report.setDataDaAnalisa(LocalDateTime.now());
        report.setSupervisor(supervisor);
        reportRepository.save(report);

        return ResponseEntity.ok().build();
    }
    private Report CriarReport(ReportCreateDTO reportDTO,Long unidadeId){
        Report report = new Report();
        UnidadeDeConservacao unidade = unidadeRepository.findById(unidadeId)
                .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(reportDTO.UsuarioId())
                .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

        report.setUnidade(unidade);
        report.setUsuario(usuario);
        report.setDescricao(reportDTO.Descricao());
        report.setTipo(TipoDeIncidente.StringParaTipo(reportDTO.Tipo()));
        report.setDataDoOcorrido(LocalDateTime.parse(reportDTO.DataDoOcorrido()));
        report.setStatus(StatusReport.PENDENTE);

        return report;
    }
}
