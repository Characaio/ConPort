package com.example.ecoportapi.Services;


import com.example.ecoportapi.DTOs.Request.ImagemProcessada;
import com.example.ecoportapi.DTOs.Request.LocalizacaoDTO;
import com.example.ecoportapi.DTOs.Request.ReportCreateDTO;
import com.example.ecoportapi.DTOs.Request.ReportStatusAnalise;
import com.example.ecoportapi.DTOs.Response.ReportExpandidoDTO;
import com.example.ecoportapi.DTOs.Response.ReportResumidoDTO;
import com.example.ecoportapi.Exceptions.ReportNaoEncontrado;
import com.example.ecoportapi.Exceptions.SupervisorNaoEncontrado;
import com.example.ecoportapi.Exceptions.UnidadeNaoEncontrada;
import com.example.ecoportapi.Exceptions.UsuarioNaoEncontrado;
import com.example.ecoportapi.Models.*;
import com.example.ecoportapi.Models.Enums.*;
import com.example.ecoportapi.Repositories.ReportRepository;
import com.example.ecoportapi.Repositories.SupervisorRepository;
import com.example.ecoportapi.Repositories.UnidadeRepository;
import com.example.ecoportapi.Repositories.UsuarioRepository;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAmount;
import java.util.*;

@Service
public class ReportService {

    private final ReportRepository reportRepository;
    private final UnidadeRepository unidadeRepository;
    private final UsuarioRepository usuarioRepository;
    private final SupervisorRepository supervisorRepository;
    private final ImagemService imagemService;

    public ReportService(ReportRepository reportRepository, UnidadeRepository unidadeRepository, UsuarioRepository usuarioRepository, SupervisorRepository supervisorRepository, ImagemService imagemService) {
        this.reportRepository = reportRepository;
        this.unidadeRepository = unidadeRepository;
        this.usuarioRepository = usuarioRepository;
        this.supervisorRepository = supervisorRepository;
        this.imagemService = imagemService;
    }

    public ReportExpandidoDTO PegarReportCompleto(Long id){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Nao Encontrado"));

        return new ReportExpandidoDTO(report);
    }
    public ReportResumidoDTO PegarReportResumido(Long id){
        return reportRepository.PegarReportResumido(id);
    }

    private Integer CalcularConfianca(Report novoReport, Report reportExistente){

        Integer confianca = 0;

        if (novoReport.getUnidade().getId().equals(reportExistente.getUnidade().getId())){

        }

        if (novoReport.getTipo().equals(reportExistente.getTipo())){

        }

        confianca += CalcularConfiancaLocalizacao(novoReport,reportExistente);

        confianca += CalcularConfiancaData(novoReport,reportExistente);

        return confianca;
    }

    private double CalcularDistancia(
            double latitude1,
            double longitude1,
            double latitude2,
            double longitude2) {

        final double RAIO_TERRA = 6371000; // metros

        double lat1 = Math.toRadians(latitude1);
        double lat2 = Math.toRadians(latitude2);

        double diferencaLatitude =
                Math.toRadians(latitude2 - latitude1);

        double diferencaLongitude =
                Math.toRadians(longitude2 - longitude1);

        double a = Math.sin(diferencaLatitude / 2)
                * Math.sin(diferencaLatitude / 2)
                + Math.cos(lat1)
                * Math.cos(lat2)
                * Math.sin(diferencaLongitude / 2)
                * Math.sin(diferencaLongitude / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return RAIO_TERRA * c;
    }

    private Integer CalcularConfiancaLocalizacao(Report novo, Report existente) {

        double distancia = CalcularDistancia(
                novo.getLatitude(),
                novo.getLongitude(),
                existente.getLatitude(),
                existente.getLongitude()
        );

        if (distancia <= 50) {
            return 30;
        }

        if (distancia <= 100) {
            return 25;
        }

        if (distancia <= 250) {
            return 20;
        }

        if (distancia <= 500) {
            return 10;
        }

        return 0;
    }

    private Integer CalcularConfiancaData(Report novoReport, Report reportExistente){
        LocalDateTime dataNova = novoReport.getDataDoOcorrido();
        LocalDateTime dataExistente = novoReport.getDataDoOcorrido();

        Long minutos = Math.abs(
                Duration.between(dataNova,dataExistente)
                .toMinutes()
        );
        if (minutos <= 10) {
            return 20;
        }

        if (minutos <= 30) {
            return 15;
        }

        if (minutos <= 60) {
            return 10;
        }

        if (minutos <= 180) {
            return 5;
        }
        return 0;
    }

    private boolean VerificarReportDuplicado(Report novoReport){
        List<Report> reportsPossiveis = reportRepository
                .findByUnidadeIdAndUsuarioId(
                        novoReport.getUnidade().getId(),
                        novoReport.getUsuario().getId()
                );
        for (Report report : reportsPossiveis){
            Integer confianca = CalcularConfianca(novoReport,report);

            if (confianca >= 70){
                return true;
            }
        }
        return false;
    }

    public ResponseEntity<?> PostarReport(
            ReportCreateDTO reportDTO,
            LocalizacaoDTO localizacaoDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = CriarReport(reportDTO,localizacaoDTO,imagens, unidadeId);

        if (VerificarReportDuplicado(report)){
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Report ja existe");
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(reportRepository.save(report));
    }

    public ReportExpandidoDTO PostarAnalise(Long id, ReportStatusAnalise reportStatusAnalise){
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new ReportNaoEncontrado("Report Não Encontrado"));
        SupervisorDeUnidade supervisor = supervisorRepository.findById(reportStatusAnalise.SupervisorId())
                        .orElseThrow(() -> new SupervisorNaoEncontrado("Supervisor Não Encontrado"));
        report.setStatus(StatusReport.StringParaTipo(reportStatusAnalise.Status()));
        report.setDataDaAnalisa(LocalDateTime.now());
        report.setSupervisor(supervisor);
        reportRepository.save(report);

        return new ReportExpandidoDTO(report);
    }
    private Report CriarReport(
            ReportCreateDTO reportDTO,
            LocalizacaoDTO localizaoDTO,
            List<MultipartFile> imagens,
            Long unidadeId) throws IOException {
        Report report = new Report();
        List<ImagemProcessada> imagensProcessadas = imagemService.SalvarImagens(imagens);
        UnidadeDeConservacao unidade = unidadeRepository.findById(unidadeId)
                .orElseThrow(() -> new UnidadeNaoEncontrada("Unidade não encontrada"));

        Usuario usuario = usuarioRepository.findById(reportDTO.UsuarioId())
                .orElseThrow(() -> new UsuarioNaoEncontrado("Usuario não encontrado"));

        report.setUnidade(unidade);
        report.setUsuario(usuario);
        report.setDescricao(reportDTO.Descricao());
        report.setTipo(TipoDeIncidente.StringParaTipo(reportDTO.Tipo()));
        report.setDataDoOcorrido(LocalDateTime.parse(reportDTO.DataDoOcorrido()));
        report.setPrioridade(reportDTO.Prioridade());
        report.setStatus(StatusReport.PENDENTE);
        report.setLocalizacaoOrigem(LocalizacaoOrigem.NAO_INFORMADA);

        if (localizaoDTO != null){
            report.setLongitude(localizaoDTO.Longitude());
            report.setLatitude(localizaoDTO.Latitude());
            report.setLocalizacaoOrigem(localizaoDTO;
        } else {
            for (ImagemProcessada imagem : imagensProcessadas){
                if (imagem.Latitude() != null && imagem.Longitude() != null){
                    report.setLatitude(imagem.Latitude());
                    report.setLongitude(imagem.Longitude());
                    report.setLocalizacaoOrigem(LocalizacaoOrigem.IMAGEM_EXIF);
                    break;
                }
            }
        }
        List<String> imagensCaminho = imagensProcessadas
                .stream()
                .map(ImagemProcessada::NomeArquivo)
                .toList();
        report.setImagensAnexadas(imagensCaminho);
        return report;
    }
}
